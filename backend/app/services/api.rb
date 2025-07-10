module Api
  BASE_URL = configatron.api.url
  EVENTS_URL = "#{BASE_URL}/api/v1/sport/football/scheduled-events/{{date}}".freeze
  INCIDENTS_URL = "#{BASE_URL}/api/v1/event/{{match_id}}/incidents".freeze
  SEARCH_URL = "#{BASE_URL}/api/v1/search/{{search}}/0".freeze
  NEAR_EVENTS_URL = "#{BASE_URL}/api/v1/team/{{team_id}}/near-events".freeze
  SEASONS_URL = "#{BASE_URL}/api/v1/unique-tournament/{{tournament_id}}/seasons".freeze
  TOURNAMENT_EVENTS_URL = "#{BASE_URL}/api/v1/unique-tournament/{{tournament_id}}/season/{{season_id}}/events/next/0".freeze

  FOOTBALL = 'Football'.freeze
  UNIQUE_TOURNAMENT = 'uniqueTournament'.freeze
  TEAM = 'team'.freeze
  MALE = 'M'.freeze

  class Client
    def self.request(url) 
      HTTParty.get(url)
    end

    def self.fetch_events(date)
      url = Api::EVENTS_URL.sub '{{date}}', date
      response = self.request(url)

      response.parsed_response['events']&.map { |e| Event.from_hash(e) }
    end

    def self.fetch_incidents(event)
      url = Api::INCIDENTS_URL.sub '{{match_id}}', event.ss_id.to_s
      response = self.request(url)

      incidents = response.parsed_response['incidents']&.map do |i|
        Incident.from_hash(i.merge({ event: event }))
      rescue ActiveRecord::RecordInvalid
        Rails.logger.info("Incident with id #{i['id']} already exists, ignoring")
        nil
      end

      incidents&.compact
    end

    def self.fetch_seasons(tournament)
      url = Api::SEASONS_URL.sub '{{tournament_id}}', tournament.ss_id.to_s
      response = self.request(url)

      seasons = response.parsed_response['seasons']&.map do |s|
        Season.from_hash(s.merge({ tournament: tournament }))
      end

      seasons&.compact
    end

    def self.fetch_tournament_todays_events(tournament)
      url = Api::TOURNAMENT_EVENTS_URL.sub('{{tournament_id}}', tournament.ss_id.to_s)
                                      .sub('{{season_id}}', tournament.seasons.current.ss_id.to_s)
      response = self.request(url)

      events = response.parsed_response['events']&.map do |e|
        next unless Time.at(e.fetch('startTimestamp')).to_date == Date.today

        Event.from_hash(e)
      end

      events&.compact
    end

    def self._search(search, &block)
      sanitized_search = search.gsub('/', ' ')
      url = Api::SEARCH_URL.sub '{{search}}', ERB::Util.url_encode(sanitized_search)
      response = self.request(url)

      Rails.logger.info("Search Response #{response.parsed_response}")

      response.parsed_response['results']&.detect(&block)
    end

    def self.search_team(team_search)
      result = _search(team_search) do |candidate|
        next unless candidate['type'] == Api::TEAM
        next unless candidate['entity']['sport']['name'] == Api::FOOTBALL
        next unless candidate['entity']['gender'] == Api::MALE

        true
      end

      team = Team.from_hash(result['entity']) if result
      SearchCache.create(search: team_search, team: team) if team

      team
    end

    def self.search_tournament(tournament_search)
      result = _search(tournament_search) do |candidate|
        next unless candidate['type'] == Api::UNIQUE_TOURNAMENT
        next unless candidate['entity']['category']['sport']['name'] == Api::FOOTBALL

        true
      end

      if result
        tournament = Tournament.from_hash(result['entity']) if result
        fetch_seasons(tournament)
      end

      tournament
    end


    def self.near_events(team)
      url = Api::NEAR_EVENTS_URL.sub '{{team_id}}', team.ss_id
      Rails.logger.info "Getting near events from #{url}"
      response = self.request(url)
      events = response.parsed_response
      previous_event = events['previousEvent']
      Rails.logger.info "Previous event #{previous_event}"
      next_event = events['nextEvent']
      Rails.logger.info "Next event #{next_event}"

      { previous: previous_event, next: next_event }
    end

    def self.todays_event(team)
      events = near_events team
      previous_event = events[:previous]
      next_event = events[:next]

      if previous_event
        Rails.logger.info "Previous event: #{previous_event['slug']} - #{previous_event['startTimestamp']}"
      end

      Rails.logger.info "Next event: #{next_event['slug']} - #{next_event['startTimestamp']}" if next_event
      if previous_event.fetch('status', {}).fetch('type') == 'inprogress'
        Event.from_hash(previous_event)
      elsif previous_event && Time.at(previous_event.fetch('startTimestamp')).to_date == Date.today
        Event.from_hash(previous_event)
      elsif next_event && Time.at(next_event.fetch('startTimestamp')).to_date == Date.today
        Event.from_hash(next_event)
      end
    end

    def self.tomorrows_event(team)
      next_event = near_events(team)[:next]

      Rails.logger.info "Next event: #{next_event['slug']} - #{next_event['startTimestamp']}" if next_event

      return nil unless next_event && Time.at(next_event.fetch('startTimestamp')).to_date == Date.tomorrow

      Event.from_hash(next_event)
    end
  end
end

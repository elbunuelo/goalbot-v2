module Api
  BASE_URL = configatron.api.url
  EVENTS_URL = "#{BASE_URL}/api/v1/sport/football/scheduled-events/{{date}}".freeze
  INCIDENTS_URL = "#{BASE_URL}/api/v1/event/{{match_id}}/incidents".freeze
  SEARCH_URL = "#{BASE_URL}/api/v1/search/{{search}}/0".freeze
  NEAR_EVENTS_URL = "#{BASE_URL}/api/v1/team/{{team_id}}/near-events".freeze

  FOOTBALL = 'Football'.freeze
  UNIQUE_TOURNAMENT = 'uniqueTournament'.freeze
  TEAM = 'team'.freeze
  MALE = 'M'.freeze

  class Client
    def self.fetch_events(date)
      url = Api::EVENTS_URL.sub '{{date}}', date
      response = HTTParty.get(url)

      response.parsed_response['events']&.map { |e| Event.from_hash(e) }
    end

    def self.fetch_incidents(event)
      url = Api::INCIDENTS_URL.sub '{{match_id}}', event.ss_id.to_s
      response = HTTParty.get(url)

      incidents = response.parsed_response['incidents']&.map do |i|
        Incident.from_hash(i.merge({ event: event }))
      rescue ActiveRecord::RecordInvalid
        Rails.logger.info("Incident with id #{i['id']} already exists, ignoring")
        nil
      end

      incidents&.compact
    end

    def self._search(search, &block)
      sanitized_search = search.gsub('/', ' ')
      url = Api::SEARCH_URL.sub '{{search}}', ERB::Util.url_encode(sanitized_search)
      response = HTTParty.get(url)

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

    def self.todays_event(team)
      url = Api::NEAR_EVENTS_URL.sub '{{team_id}}', team.ss_id
      Rails.logger.info "Getting near events from #{url}"
      response = HTTParty.get(url)
      events = response.parsed_response
      previous_event = events['previousEvent']
      next_event = events['nextEvent']

      if previous_event
        Rails.logger.info "Previous event: #{previous_event['slug']} - #{previous_event['startTimestamp']}"
      end

      Rails.logger.info "Next event: #{next_event['slug']} - #{next_event['startTimestamp']}" if next_event
      if previous_event['status']['type'] == 'inprogress'
        Event.from_hash(previous_event)
      elsif Time.at(previous_event['startTimestamp']).to_date == Date.today
        Event.from_hash(previous_event)
      elsif next_event && Time.at(next_event['startTimestamp']).to_date == Date.today
        Event.from_hash(next_event)
      end
    end
  end
end

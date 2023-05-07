class EventManager
  def self.find_matching(search)
    Rails.logger.info("[Event Search] Searching events matching #{search}")
    team = Team.search search

    event = Event.find_team_event_today(team)
    Rails.logger.info('[Event Search] Found event in database.') if event
    event ||= Api::Client.todays_event team
    raise Errors::EventNotFound, "No Events for #{search} found." unless event

    Rails.logger.info("[Event Search] Found event #{event.slug}")

    after_start_time = Time.now >= Time.at(event.start_timestamp)
    fetch_incidents(event) if after_start_time

    raise Errors::EventNotFound, I18n.t(:match_not_found) unless event

    event
  end

  def self.fetch_incidents(event)
    Resque.logger.info "[Incident Fetch] Fetching incidents for #{event.slug}"

    before_start_time = Time.now < Time.at(event.start_timestamp)

    if before_start_time
      Resque.logger.info "[Incident Fetch] Event #{event.slug} hasn't started yet"
      return
    end
    incidents = Api::Client.fetch_incidents(event)

    Resque.logger.info "[Incident Fetch] Found #{incidents.count} incidents" if incidents

    incidents&.each do |incident|
      if incident.incident_type == Incidents::Types::PERIOD && incident.text == 'FT'
        Resque.logger.info "[Incident Fetch] Game ended, removing schedule #{event.schedule_name}"
        Resque.remove_schedule(event.schedule_name)
        event.update(finished: true)
        break
      end
    end
  end
end

class Olympics
  BASE_URL = 'https://sph-s-api.olympics.com'
  EVENTS_URL = "summer/schedules/api/ENG/schedule/day/{{date}}"

  COMPETITION_TYPE = {
   Individual: 'ATH',
   Team: 'HTEAM'
  }

  def self.get(url)
    HTTParty.get("#{BASE_URL}/#{url}", {
      headers: {
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0',
        'Accept' => 'application/json'
      }
    })
  end

  def self.fetch_events(date)
    url = EVENTS_URL.sub '{{date}}', date
    response = get(url)
    response.parsed_response['units']
  end

  def self.todays_events
    events = fetch_events(Time.now.strftime('%Y-%m-%d'))

    events_message events
  end

  def self.events_message(events)
    messages = []
    message = ''
    events.each do |e|
      start_date = Time.zone.parse(e['startDate'])
      start_time = start_date.strftime('%H:%M:%S')
      next unless start_date > Time.now

      event_message = "[#{start_time}] #{e['disciplineName']} #{e['eventUnitName']}"
      if e['eventUnitType'] == COMPETITION_TYPE[:Team] && e['competitors'].present?
        competitors = e['competitors']
        event_message += " |  #{competitors[0]['name']} - #{competitors[1]['name']}"
      end
      event_message += "\n"
      if "#{message}#{event_message}".length > 4096
        messages << message
        message = event_message
      else
        message += event_message
      end
    end
    messages << message

    messages
  end
end

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
    pp date
    url = EVENTS_URL.sub '{{date}}', date
    response = get(url)
    response.parsed_response['units']
  end

  def self.todays_events
    events = fetch_events(Time.now.strftime('%Y-%m-%d'))

    events_message events
  end

  def self.events_message(events)
    message = ''
    events.each do |e|
      start_date = DateTime.parse(e['startDate']).strftime('%H:%M:%S')
      message += "[#{start_date}] #{e['disciplineName']} #{e['eventUnitName']}"
      if e['eventUnitType'] == COMPETITION_TYPE[:Team] && e['competitors'].present?
        competitors = e['competitors']
        message += " |  #{competitors[0]['name']} - #{competitors[1]['name']}"
      end
      message += "\n"
    end

    message
  end
end

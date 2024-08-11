class Olympics
  EVENTS_URL = 'https://sph-s-api.olympics.com/summer/schedules/api/ENG/schedule/day/{{date}}'
  MEDALS_URL = 'https://sph-i-api.olympics.com/summer/info/api/ENG/widgets/medals-table'

  COMPETITION_TYPE = {
   Individual: 'ATH',
   Team: 'HTEAM'
  }

  def self.get(url)
    HTTParty.get(url, {
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

  def self.medals
    medals = fetch_medals
    medals_message medals
  end

  def self.fetch_medals
    response = get(MEDALS_URL)

    response.parsed_response['medalsTable']
  end

  def self.medals_message(medals)
    header = "#{'Country'.ljust(19)} Gold Silver Bronze Total"
    message = "```\n#{header}\n"
    message += "#{'-' * header.length}\n"
    medals[0..20].each do |medal|
      country_name = if medal['description'].length <= 19
                       medal['description']
                     else
                       "#{medal['description'][0..18]}…"
                     end
      country = country_name.ljust(19)
      gold = medal['gold'].to_s.center(4)
      silver = medal['silver'].to_s.center(6)
      bronze = medal['bronze'].to_s.center(6)
      total = medal['total'].to_s.center(5)
      message += "#{country} #{gold} #{silver} #{bronze} #{total}\n"
    end
    message += '```'

    message
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

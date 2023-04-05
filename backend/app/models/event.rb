class Event < ApplicationRecord
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'

  has_many :incidents, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  def monitored?
    subscriptions.exists?
  end

  def schedule_name
    "#{slug}-#{date}"
  end

  def playing?
    Time.at(start_timestamp) < Time.now && !finished
  end

  def emoji
    if finished
      '🏁'
    elsif playing?
      '⚽'
    end
  end

  def title
    full_title = []
    full_title << emoji
    full_title << "[#{start_time}]" unless playing? || finished
    full_title << home_team.name

    full_title << home_score if playing? || finished
    full_title << '-'
    full_title << away_score if playing? || finished

    full_title << away_team.name
    full_title.join(' ')
  end

  def home_score
    incidents.goals.last&.home_score || 0
  end

  def away_score
    incidents.goals.last&.away_score || 0
  end

  def start_time
    Time.at(start_timestamp).strftime('%H:%M:%S')
  end

  def self.from_hash(event_data)
    event =  Event.find_by(slug: event_data['slug'])

    event || create!(
      {
        start_timestamp: event_data['startTimestamp'],
        previous_leg_ss_id: event_data.fetch('previousLegEventId', nil),
        ss_id: event_data['id'],
        slug: event_data['slug'],
        home_team: Team.from_hash(event_data['homeTeam']),
        away_team: Team.from_hash(event_data['awayTeam']),
        date: Time.at(event_data['startTimestamp']).to_date
      }
    )
  end

  def self.find_team_event_today(team)
    where('(home_team_id = ? OR away_team_id = ?) AND date = ?', team.id, team.id, Date.today)
      .last
  end
end

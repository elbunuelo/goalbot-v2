class Incident < ApplicationRecord
  belongs_to :event
  has_many :incident_messages

  before_create :maybe_set_searching_since
  after_create :maybe_schedule_search_cancellation
  after_save :maybe_cancel_message_sending
  after_update :maybe_schedule_send_subscription_messages

  scope :goals, -> { where(incident_type: Incidents::Types::GOAL).order(:time) }
  scope :goals_pending_link, -> { goals.where(search_suspended: false, video_url: nil) }

  scope :default, -> { order(:time) }

  validates :ss_id, uniqueness: true, allow_nil: true

  def self.find_pending_link_by_score(home_score, away_score)
    goals_pending_link.where(home_score: home_score, away_score: away_score).first
  end

  def video_message
    message = event.home_team.name
    message += ' ⚽' if is_home
    message += " #{home_score} - #{away_score}"
    message += ' ⚽' unless is_home
    message += " #{event.away_team.name}  "
    message += "#{player_name} " if player_name
    message += time.to_s
    message += "+#{added_time}" if added_time
    message += "'"
    message += " | #{video_url}" if video_url

    message
  end

  private

  def maybe_set_searching_since
    return unless incident_type == Incidents::Types::GOAL
    return unless event.monitored?

    self.searching_since = Time.now
  end

  def maybe_schedule_search_cancellation
    return unless incident_type == Incidents::Types::GOAL

    Resque.enqueue_in(Incidents::MAX_SEARCH_TIME, CancelGoalSearch, id)
  end

  def maybe_cancel_message_sending
    unless incident_type == Incidents::Types::VAR_DECISION && incident_class == Incidents::Classes::GOAL_NOT_AWARDED
      return
    end

    goal = event.incidents
                .where('id < ?', id)
                .where('time + COALESCE(added_time, 0) >= ?', time + (added_time || 0) - Incidents::MAX_VAR_DIFFERENCE)
                .where(player_name: player_name)
                .where(incident_type: Incidents::Types::GOAL)
                .first

    return unless goal

    goal.search_suspended = true
    goal.save
  end

  def maybe_schedule_send_subscription_messages
    return unless incident_type == Incidents::Types::GOAL

    Resque.enqueue(SendSubscriptionMessages, id)
  end

  def self.from_hash(incident_data)
    player_name = incident_data.fetch('player_name', nil) || incident_data.fetch('player', {}).fetch('name', nil)

    event = incident_data.delete(:event)
    ss_id = incident_data['id']

    incident_hash = {
      reason: incident_data.fetch('reason', nil),
      incident_class: incident_data.fetch('incidentClass', nil),
      incident_type: incident_data.fetch('incidentType', nil),
      time: incident_data.fetch('time', nil),
      is_home: incident_data.fetch('isHome', nil),
      text: incident_data.fetch('text', nil),
      home_score: incident_data.fetch('homeScore', nil),
      away_score: incident_data.fetch('awayScore', nil),
      added_time: incident_data.fetch('addedTime', nil),
      player_in: incident_data.fetch('playerIn', {}).fetch('name', nil),
      player_out: incident_data.fetch('playerOut', {}).fetch('name', nil),
      length: incident_data.fetch('length', nil),
      description: incident_data.fetch('description', nil),
      player_name: player_name
    }

    incident = Incident.find_by(ss_id: ss_id) if ss_id
    if incident
      incident.update(incident_hash)
    else
      incident = event.incidents.find_or_initialize_by(incident_hash)
      incident.ss_id = ss_id
      incident.save
    end

    incident
  end
end

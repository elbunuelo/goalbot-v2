class Subscription < ApplicationRecord
  belongs_to :event

  after_save :schedule_incident_fetch
  after_save :schedule_game_start_messages

  has_many :incident_messages, dependent: :delete_all

  scope :active, lambda { |service, conversation_id|
    joins(:event)
      .where(
        service: service,
        conversation_id: conversation_id,
        'event.date' => Date.today
      )
      .order('event.start_timestamp')
  }

  private

  def schedule_incident_fetch
    if Resque.fetch_schedule event.schedule_name
      Rails.logger.info("[Subscription] Found schedule for #{event.schedule_name}")
      return
    end

    every = '1m'
    Rails.logger.info("[Subscription] It is #{Time.now}, the event starts at #{Time.at(event.start_timestamp)}")
    if Time.now.to_i < event.start_timestamp
      Rails.logger.info("[Subscription] Fetching will start at #{Time.at(event.start_timestamp)}")
      every = [every, { first_at: Time.at(event.start_timestamp) }]
    end

    Rails.logger.info("[Subscription] Scheduling incident fetch for #{event.schedule_name}")

    schedule = Resque.set_schedule(
      event.schedule_name,
      {
        class: 'FetchEventIncidents',
        args: event.id,
        persist: true,
        every: every
      }
    )

    Rails.logger.info("[Subscription] Created schedule #{schedule.inspect}")
  end

  def schedule_game_start_messages
    if Time.now.to_i > event.start_timestamp
      Rails.logger.info('[Subscription] Game already started, not scheduling game start messages.')
      return
    end
    start_time = Time.at(event.start_timestamp)

    Rails.logger.info("[Subscription] Scheduling game start messages at #{start_time}.")
    Resque.delay_or_enqueue_at(start_time, SendGameStartedMessages, event.id)
  end
end

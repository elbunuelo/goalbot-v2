class SendSubscriptionMessages
  @queue = :incidents

  def self.perform(incident_id)
    incident = Incident.find(incident_id)
    if incident.search_suspended
      Resque.logger.info('[SendSubscriptionMessages] Search for this goal has been suspended, skipping.')
      return
    end

    if incident.notifications_sent
      Resque.logger.info('[SendSubscriptionMessages] This goal has already been processed, skipping.')
      return
    end

    incident.event.subscriptions.each do |subscription|
      next unless subscription.conversation_id.present?

      Telegram::Bot::Client.run(configatron.telegram_token) do |bot|
        bot.api.send_message(chat_id: subscription.conversation_id, text: incident.video_message)
      end
    end

    incident.notifications_sent = true
    incident.save
  end
end

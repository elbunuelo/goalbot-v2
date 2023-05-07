class SendSubscriptionMessages
  @queue = :incidents

  def self.perform(incident_id)
    incident = Incident.find(incident_id)
    if incident.search_suspended
      Resque.logger.info('[SendSubscriptionMessages] Search for this goal has been suspended, skipping.')
      return
    end

    # if incident.notifications_sent
    #   Resque.logger.info('[SendSubscriptionMessages] This goal has already been processed, skipping.')
    #   return
    # end

    incident.event.subscriptions.each do |subscription|
      next unless subscription.conversation_id.present?

      Telegram::Bot::Client.run(configatron.telegram_token) do |bot|
        incident_message = incident.incident_messages.find_by(subscription: subscription)
        if incident_message
          Resque.logger.info('[SendSubscriptionMessages] Updating message text')
          bot.api.edit_message_text(
            chat_id: subscription.conversation_id,
            message_id: incident_message.message_id,
            text: incident.video_message
          )
        else
          Resque.logger.info('[SendSubscriptionMessages] Sending new message')
          message = bot.api.send_message(chat_id: subscription.conversation_id, text: incident.video_message)

          unless message['ok']
            Resque.logger.error("Error sending message #{message}")
            next
          end

          message_id = message['result']['message_id']
          incident.incident_messages.create(message_id: message_id , subscription: subscription)
        end
      end
    end

    # incident.notifications_sent = true
    # incident.save
  end
end

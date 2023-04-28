class SendGameStartedMessages
  @queue = :incidents

  def self.perform(event_id)
    event = Event.find(event_id)

    event.subscriptions.each do |subscription|
      next unless subscription.conversation_id.present?

      Telegram::Bot::Client.run(configatron.telegram_token) do |bot|
        bot.api.send_message(chat_id: subscription.conversation_id, text: event.game_started_message)
      end
    end
  end
end

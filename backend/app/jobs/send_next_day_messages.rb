require 'telegram/bot'

class SendNextDayMessages
  @queue = :incidents

  def self.perform
    TeamSubscription.conversations.each do |conversation_info|
      conversation_id = conversation_info[0]
      service = conversation_info[1]
      messages = []
      TeamSubscription.joins(:team).for_conversation(conversation_id, service).each do |subscription|
        event = Api::Client.tomorrows_event subscription.team
        next unless event

        messages << event.title
      end

      next unless messages.present?

      Telegram::Bot::Client.run(configatron.telegram_token) do |bot|
        full_message = "#{I18n.t(:tomorrows_matches)}\n#{messages.join('\n')}"
        bot.api.send_message(chat_id: conversation_id, text: full_message)
      end
    end
  end
end

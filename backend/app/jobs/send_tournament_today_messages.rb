require 'telegram/bot'

class SendTournamentTodayMessages
  @queue = :incidents

  def self.perform
    TournamentSubscription.conversations.each do |conversation_info|
      conversation_id = conversation_info[0]
      service = conversation_info[1]
      messages = []
      TournamentSubscription.for_conversation(conversation_id, service).each do |subscription|
        events = Api::Client.fetch_tournament_todays_events subscription.tournament
        next if events.empty?

        messages << I18n.t(:todays_matches, tournament: subscription.tournament.name)
        events.each do |event|
          messages << event.title
        end
        messages << ''
      end

      next unless messages.present?

      Telegram::Bot::Client.run(configatron.telegram_token) do |bot|
        full_message = messages.join("\n")
        bot.api.send_message(chat_id: conversation_id, text: full_message)
      end
    end
  end
end

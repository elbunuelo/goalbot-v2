require 'telegram/bot'
HELP_TEXT = <<~HELP
  /hola - Saluda al bot.
  /seguir <equipo> - Busca y monitorea un partido. Admite varios equipos separándolos con coma (,) punto y coma (;) o fin de línea.
  /seguir_equipo <equipo> - Busca un equipo y sigue todos sus partidos. Admite varios equipos separándolos con coma (,) punto y coma (;) o fin de línea.
  /dejar <equipo> - Deja de monitorear un partido.
  /subs - Lista las suscripciones activas.
  /alias <equipo>::<alias> - Crea un alias para un equipo.
  /help - Mostrar ayuda.
HELP

SERVICE_NAME = 'Telegram'

TELEGRAM_TEAM_REGEX = '(?<team>(.+\n?)+)'
TELEGRAM_ALIAS_REGEX = "#{TELEGRAM_TEAM_REGEX}::(?<alias>.+)"

OPTIONAL_BOT_REGEX =
  def action_regex(keywords, action_params = [])
    keywords_part = "#{keywords.join('|')}"
    params_part = action_params.present? ? " #{action_params.join(' ')}" : ''

    "^/(bot\\s+)?(#{keywords_part})#{params_part}"
  end

ACTIONS = {
  follow: action_regex(%w[follow seguir folgen], [TELEGRAM_TEAM_REGEX]),
  follow_team: action_regex(%w[follow_team seguir_equipo mannschaft_folgen], [TELEGRAM_TEAM_REGEX]),
  unfollow: action_regex(%w[unfollow dejar parar unfolgen], [TELEGRAM_TEAM_REGEX]),
  alias: action_regex(%w[alias], [TELEGRAM_ALIAS_REGEX]),
  hello: action_regex(%w[hello hola oi hallo]),
  help: action_regex(%w[help ayuda ajuda hilfe start]),
  subs: action_regex(%w[subs suscripciones assinaturas abonnements])

}

def action(action_name, message, &block)
  return unless message.respond_to?(:text) && message.text

  Rails.logger.info("[Telegram Client] Matching against #{ACTIONS[action_name]}")
  message.text.match(ACTIONS[action_name], &block)
end

def set_locale(message)
  Rails.logger.info "[Telegram Client] Language code #{message.from.language_code}"
  new_locale = message.from.language_code[0..1] if message.from.language_code
  if I18n.locale_available? new_locale
    I18n.locale = new_locale
  else
    I18n.locale = I18n.default_locale
  end
end

task telegram_client: :environment do
  Rails.logger.info '[Telegram Client] Initializing telegram client'
  Telegram::Bot::Client.run(configatron.telegram_token) do |bot|
    bot.listen do |message|
      next unless message.respond_to?(:text) && message.text
      Rails.logger.info "[Telegram Client] Message received #{message}"

      set_locale(message)
      Rails.logger.info "[Telegram Client] Locale set to #{I18n.locale}"

      chat_id = message.chat.id
      subscription_params = {
        service: SERVICE_NAME,
        conversation_id: chat_id
      }

      action :follow, message do |params|
        Rails.logger.info "[Telegram Client] Following match with search #{params[:team]}"
        teams = params[:team].split(/[,;\n]/)
        teams.each do |team|
          next if team.empty?

          Rails.logger.info "[Telegram Client] Searching for team #{team}"
          message = SubscriptionManager.create_subscription(team.strip, subscription_params)

          bot.api.send_message(chat_id:, text: message)
        end
      end

      action :follow_team, message do |params|
        Rails.logger.info "[Telegram Client] Following team with search #{params[:team]}"
        teams = params[:team].split(/[,;\n]/)
        teams.each do |team|
          next if team.empty?

          Rails.logger.info "[Telegram Client] Searching for team #{team}"
          message = SubscriptionManager.create_team_subscription(team.strip, subscription_params)

          bot.api.send_message(chat_id:, text: message)
        end
      end

      action :unfollow, message do |params|
        Rails.logger.info "[Telegram Client] Unfollowing match with search #{params[:team]}"
        teams = params[:team].split(/[,;\n]/)
        teams.each do |team|
          next if team.empty?

          Rails.logger.info "[Telegram Client] Searching for team #{team}"
          message = SubscriptionManager.delete_subscription(team.strip, subscription_params)

          bot.api.send_message(chat_id:, text: message)
        end
      end

      action :hello, message do |_params|
        bot.api.send_message(chat_id:, text: "#{I18n.t :hello}, #{message.from.first_name}!")
      end

      action :help, message do
        bot.api.send_message(chat_id:, text: HELP_TEXT)
      end

      action :subs, message do
        message = SubscriptionManager.list_active_subscriptions(subscription_params)

        bot.api.send_message(chat_id:, text: message)
      end

      action :alias, message do |params|
        Rails.logger.info "[Telegram Client] Creating alias #{params[:team]} #{params[:alias]}"
        message = AliasManager.create_alias(params[:team], params[:alias])
        bot.api.send_message(chat_id:, text: message)
      end
    end
  end
end

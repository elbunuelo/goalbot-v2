class SubscriptionManager
  def self.create_subscription(team_search, subscription_params)
    event = EventManager.find_matching(team_search)
    subscription = event.subscriptions.find_or_initialize_by(subscription_params)

    if subscription.save
      Rails.logger.info '[SubscriptionManager] Subscription created'
      event_message = event.finished ? I18n.t(:match_finished) : I18n.t(:following_match)
      "#{event_message}\n#{event.title}"
    else
      Rails.logger.info '[SubscriptionManager] Subscription creation failed.'
      I18n.t(:could_not_create_subscription)
    end
  rescue Errors::TeamNotFound => e
    e.message
  rescue Errors::EventNotFound => e
    e.message
  end

  def self.create_team_subscription(team_search, subscription_params)
    team = Team.search(team_search)

    subscription = team.team_subscriptions.find_or_initialize_by(subscription_params)

    if subscription.save
      Rails.logger.info '[SubscriptionManager] Team Subscription created'
      create_subscription(team.name, subscription_params)
      I18n.t(:following_team, team: team.name)
    else
      Rails.logger.info '[SubscriptionManager] Team Subscription creation failed.'
      I18n.t(:could_not_create_subscription)
    end
  rescue Errors::TeamNotFound => e
    e.message
  end

  def self.create_tournament_subscription(tournament_search, subscription_params)
    tournament = Tournament.search(tournament_search)

    subscription = tournament.tournament_subscriptions.find_or_initialize_by(subscription_params)

    if subscription.save
      Rails.logger.info '[SubscriptionManager] Tournament Subscription created'
      I18n.t(:following_tournament, tournament: tournament.name)
    else
      Rails.logger.info '[SubscriptionManager] Tournament Subscription creation failed.'
      I18n.t(:could_not_create_subscription)
    end
  rescue Errors::TournamentNotFound => e
    e.message
  end

  def self.delete_subscription(team_search, subscription_params)
    event = EventManager.find_matching(team_search)
    subscription = event.subscriptions.find_by!(subscription_params)
    if subscription.destroy
      "#{I18n.t :unfollowed_match} #{event.title}"
    else
      "#{I18n.t :could_not_destroy_subscription} #{event.title}"
    end
  rescue Errors::EventNotFound => e
    e.message
  rescue ActiveRecord::RecordNotFound
    I18n.t :subscription_not_found
  end

  def self.list_active_subscriptions(subscription_params)
    subscriptions = Subscription.active(subscription_params[:service], subscription_params[:conversation_id])

    if subscriptions.empty?
      I18n.t :no_active_subscriptions
    else
      subscriptions_list = subscriptions.map { |sub| sub.event.title }.join("\n")
      "#{I18n.t :active_subscriptions}\n#{subscriptions_list}"
    end
  end
end

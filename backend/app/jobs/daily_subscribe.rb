class DailySubscribe
  @queue = :incidents

  def self.perform
    Team.joins(:team_subscriptions).each do |team|
      team.team_subscriptions.each do |team_subscription|
        SubscriptionManager.create_subscription(team.name, team_subscription.params)
      end
    end
  end
end

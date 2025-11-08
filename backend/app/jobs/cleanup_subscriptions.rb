DAILY_EVENTS = [
  "DailySubscribe",
  "SendNextDayMessages",
  "SendTournamentTodayMessages",
  "CleanupSubscriptions"
].freeze

class CleanupSubscriptions
  @queue = :incidents

  def self.perform
    Resque.schedule.each do |key, schedule|
      next if key in DAILY_EVENTS

      Resque.logger.info("[CleanupSubscriptions] Removing stuck schedule #{key}.")
      Resque.remove_schedule(key)
    end
  end
end

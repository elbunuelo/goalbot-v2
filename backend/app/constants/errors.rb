module Errors
  class TeamNotFound < StandardError
  end

  class TournamentNotFound < StandardError
  end

  class EventNotFound < StandardError
  end

  class NoGoalMatch < StandardError
  end
end

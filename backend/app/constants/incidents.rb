module Incidents
  # Maximum amount of time before giving up on the video search for a goal
  MAX_SEARCH_TIME = 5.minutes

  # Time difference (in minutes) within which a goal invalidation can be found.
  MAX_VAR_DIFFERENCE = 2

  module Types
    GOAL = 'goal'
    PERIOD = 'period'
    VAR_DECISION = 'varDecision'
  end

  module Classes
    GOAL_NOT_AWARDED = 'goalNotAwarded'
  end
end

module Incidents
  MAX_SEARCH_TIME = 15.minutes
  # Time we wait to send a goal video, expecting there might be a var
  # invalidation
  VAR_WAIT_TIME = 2.minutes

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

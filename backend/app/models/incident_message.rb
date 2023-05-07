class IncidentMessage < ApplicationRecord
  belongs_to :incident
  belongs_to :subscription
end

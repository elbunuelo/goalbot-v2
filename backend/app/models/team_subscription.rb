class TeamSubscription < ApplicationRecord
  belongs_to :team

  def params
    {
      service: service,
      conversation_id: conversation_id
    }
  end
end

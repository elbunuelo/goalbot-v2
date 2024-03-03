class TeamSubscription < ApplicationRecord
  belongs_to :team

  scope :for_conversation, ->(conversation_id, service) { where(conversation_id: conversation_id, service: service) }
  scope :conversations, -> { pluck(:conversation_id, :service).uniq }

  def params
    {
      service: service,
      conversation_id: conversation_id
    }
  end
end

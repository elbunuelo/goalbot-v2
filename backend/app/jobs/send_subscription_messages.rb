class SendSubscriptionMessages
  @queue = :incidents

  def self.perform(incident_id)
    incident = Incident.find(incident_id)
    if incident.search_suspended
      Resque.logger.info('[SendSubscriptionMessages] Search for this goal has been suspended, skipping.')
      return
    end

    if incident.notifications_sent
      Resque.logger.info('[SendSubscriptionMessages] This goal has already been processed, skipping.')
      return
    end

    incident.event.subscriptions.each do |subscription|
      next unless subscription.conversation_id.present?

      Resque.logger.info('[SendSubscriptionMessages] Sending http request to bot')
      response = HTTParty.post(
        configatron.hangouts.callback_url,
        {
          body: { sendto: subscription.conversation_id, key: configatron.hangouts.api_key,
                  content: incident.video_message }.to_json,
          headers: { 'Content-Type' => 'application/json' },
          verify: false
        }
      )
      Resque.logger.info("[SendSubscriptionMessages] Response received #{response.code} - #{response.parsed_response}")
    end

    incident.notifications_sent = true
    incident.save
  end
end

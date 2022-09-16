# frozen_string_literal: true

require_relative 'auth_strategy'

module Redd
  module AuthStrategies
    # A password-based authentication scheme. Requests all scopes.
    class Script < AuthStrategy
      def initialize(client_id:, secret:, username:, password:, **kwargs)
        super(client_id: client_id, secret: secret, **kwargs)
        @username = username
        @password = password
      end

      # Perform authentication and return the resulting access object
      # @return [Access] the access token object
      def authenticate
        request_access('password', username: @username, password: @password)
      end

      # Since the access isn't used for refreshing, the strategy is inherently
      # refreshable.
      # @return [true]
      def refreshable?(_access)
        true
      end

      # Refresh the authentication and return the refreshed access
      # @return [Access] the new access
      def refresh(_)
        authenticate
      end
    end
  end
end

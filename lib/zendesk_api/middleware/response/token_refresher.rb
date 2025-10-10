module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Response
      # This middleware is responsible for obtaining new access and refresh tokens
      # when the current expires.
      class TokenRefresher < Faraday::Middleware
        ERROR_CODES = [401].freeze

        def initialize(app, config)
          super(app)
          @config = config
        end

        def on_complete(env)
          return unless ERROR_CODES.include?(env[:status])

          ZendeskAPI::TokenRefresher.new(@config).refresh_token do |access_token, refresh_token|
            if @config.refresh_token_callback.is_a?(Proc)
              @config.refresh_token_callback.call(access_token, refresh_token)
            end
          end
        end
      end
    end
  end
end

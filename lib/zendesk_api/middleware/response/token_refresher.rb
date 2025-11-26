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
          @refresh_tokens_callback = @config.refresh_tokens_callback.is_a?(Proc) ? @config.refresh_tokens_callback : ->(_, _) {}
        end

        def on_complete(env)
          return unless ERROR_CODES.include?(env[:status])

          ZendeskAPI::TokenRefresher.new(@config).refresh_token do |access_token, refresh_token|
            @refresh_tokens_callback.call(access_token, refresh_token)
          end
        end
      end
    end
  end
end

require 'faraday/middleware'
require 'zendesk_api/error'

module ZendeskAPI
  module Middleware
    # @private
    module Request
      # Faraday middleware to handle HTTP Status 429 (rate limiting) / 503 (maintenance)
      # @private
      class RaiseRateLimited < Faraday::Middleware
        ERROR_CODES = [429, 503].freeze

        def initialize(app, options = {})
          super(app)
          @logger = options[:logger]
        end

        def call(env)
          response = @app.call(env)

          if ERROR_CODES.include?(response.env[:status])
            @logger&.warn 'You have been rate limited. Raising error...'
            raise Error::RateLimited, env
          else
            response
          end
        end
      end
    end
  end
end

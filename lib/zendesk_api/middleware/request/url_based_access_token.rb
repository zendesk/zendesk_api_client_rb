module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Request
      class UrlBasedAccessToken < Faraday::Middleware
        def initialize(app, token)
          super(app)
          @token = token
        end

        def call(env)
          env[:url] += "?access_token=#{@token}"
          @app.call(env)
        end
      end
    end
  end
end

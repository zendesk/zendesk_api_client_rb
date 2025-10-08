module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Response
      class RefreshAccessToken < Faraday::Middleware
        ERROR_CODES = [401].freeze

        #def initialize(app) , token, refresh_token = nil)
          #@token = token
          #@refresh_token = refresh_token
        #end
        def initialize(app, client)
          super(app)
          @client = client
        end

        def on_complete(env)
          return unless ERROR_CODES.include?(env[:status])

          return unless @client.config.client_id
          return unless @client.config.client_secret
          return unless @client.config.refresh_token

          refresh_token
        end

        def refresh_token
          p "REFRESH TOKEN"
          response = connection.post "/oauth/tokens" do |req|
            req.body = {
              grant_type: "refresh_token",
              refresh_token: @client.config.refresh_token,
              client_id: @client.config.client_id,
              client_secret: @client.config.client_secret,
              expires_in: 60 * 5, #@client.config.token_expiration
              #refresh_token_expires_in: @client.config.refresh_token_expiration
            }
          end
          @client.config.access_token = response.body["access_token"]
          @client.config.refresh_token = response.body["refresh_token"]
        end

        def connection
          @connection ||= Faraday.new(faraday_options) do |builder|
            # response
            builder.use ZendeskAPI::Middleware::Response::RaiseError
            builder.use ZendeskAPI::Middleware::Response::Logger, @client.config.logger if @client.config.logger
            builder.use ZendeskAPI::Middleware::Response::ParseJson
            builder.use ZendeskAPI::Middleware::Response::SanitizeResponse
            builder.use ZendeskAPI::Middleware::Request::EncodeJson

            # Should always be first in the stack
            # TODO: Should it be here at all???
            if @client.config.retry
              builder.use ZendeskAPI::Middleware::Request::Retry,
                          :logger => @client.config.logger,
                          :retry_codes => @client.config.retry_codes,
                          :retry_on_exception => @client.config.retry_on_exception
            end
            if @client.config.raise_error_when_rate_limited
              builder.use ZendeskAPI::Middleware::Request::RaiseRateLimited, :logger => @client.config.logger
            end

            adapter = @client.config.adapter || Faraday.default_adapter
            builder.adapter(*adapter, &@client.config.adapter_proc)
          end
        end

        def faraday_options
          {
            url: @client.config.url
          }
        end
      end
    end
  end
end

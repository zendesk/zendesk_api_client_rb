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

          return unless @config.client_id
          return unless @config.client_secret
          return unless @config.refresh_token

          refresh_token
        end

        def refresh_token
          response = connection.post "/oauth/tokens" do |req|
            req.body = {
              grant_type: "refresh_token",
              refresh_token: @config.refresh_token,
              client_id: @config.client_id,
              client_secret: @config.client_secret
            }.tap do |params|
              params.merge!(expires_in: @config.access_token_expiration) if @config.access_token_expiration
              params.merge!(refresh_token_expires_in: @config.refresh_token_expiration) if @config.refresh_token_expiration
            end
          end
          @config.access_token = response.body["access_token"]
          @config.refresh_token = response.body["refresh_token"]

          return unless @config.refresh_token_callback.is_a?(Proc)

          @config.refresh_token_callback.call(@config.access_token, @config.refresh_token)
        end

        def connection
          @connection ||= Faraday.new(faraday_options) do |builder|
            builder.use ZendeskAPI::Middleware::Response::RaiseError
            builder.use ZendeskAPI::Middleware::Response::Logger, @config.logger if @config.logger
            builder.use ZendeskAPI::Middleware::Response::ParseJson
            builder.use ZendeskAPI::Middleware::Response::SanitizeResponse
            builder.use ZendeskAPI::Middleware::Request::EncodeJson

            adapter = @config.adapter || Faraday.default_adapter
            builder.adapter(*adapter, &@config.adapter_proc)
          end
        end

        def faraday_options
          {
            url: @config.url
          }
        end
      end
    end
  end
end

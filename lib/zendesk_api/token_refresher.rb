module ZendeskAPI
  # Obtains new OAuth access and refresh tokens.
  class TokenRefresher
    def initialize(config)
      @config = config
    end

    def valid_config?
      return false unless @config.client_id
      return false unless @config.client_secret
      return false unless @config.refresh_token

      true
    end

    def refresh_token
      return unless valid_config?

      response = connection.post "/oauth/tokens" do |req|
        req.body = {
          grant_type: "refresh_token",
          refresh_token: @config.refresh_token,
          client_id: @config.client_id,
          client_secret: @config.client_secret
        }.tap do |params|
          params[:expires_in] = @config.access_token_expiration if @config.access_token_expiration
          params[:refresh_token_expires_in] = @config.refresh_token_expiration if @config.refresh_token_expiration
        end
      end
      new_access_token = response.body["access_token"]
      new_refresh_token = response.body["refresh_token"]
      @config.access_token = new_access_token
      @config.refresh_token = new_refresh_token

      yield new_access_token, new_refresh_token if block_given?
    end

    private

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

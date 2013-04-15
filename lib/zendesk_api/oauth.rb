require 'oauth2'

module ZendeskAPI
  module OAuth
    OAuthProxy = Struct.new(:client)
    def oauth
      @oauth ||= OAuthProxy.new(self).extend(Methods)
    end

    module Methods
      def oauth_client
        @oauth_client ||= ::OAuth2::Client.new(options.fetch(:client_id), options.fetch(:client_secret),
          :site          => client.config.url,
          :authorize_url => '/oauth/grants',
          :token_url     => '/oauth/tokens')
      end

      def options
        client.config.oauth_options
      end

      # Grab the token
      def get_token(url)
      end

      # Return a URL to redirect to
      def authorize_url(options = {})
      end

      # Return current token's scopes
      def scopes
      end
    end
  end
end

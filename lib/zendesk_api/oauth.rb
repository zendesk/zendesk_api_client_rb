require 'oauth2'

module ZendeskAPI
  module OAuth
    def oauth(options = config.oauth_options)
      ::OAuth2::Client.new(
        options.fetch(:client_id),
        options[:client_secret],
        :site          => config.url,
        :authorize_url => '/oauth/grants',
        :token_url     => '/oauth/tokens'
      )
    rescue KeyError => e
      raise ArgumentError, "Required OAuth parameter missing: #{e.message}"
    end
  end
end

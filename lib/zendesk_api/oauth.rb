require 'oauth2'

module ZendeskAPI
  module OAuth
    def oauth
      @oauth ||= ::OAuth2::Client.new(
        config.oauth_options.fetch(:client_id),
        config.oauth_options.fetch(:client_secret),
        :site          => strip_path(config.url),
        :authorize_url => '/oauth/grants',
        :token_url     => '/oauth/tokens'
      )
    rescue KeyError => e
      raise ArgumentError, "Required OAuth parameter missing: #{e.message}"
    end

    private

    def strip_path(url)
      uri = URI.parse(url)
      uri.path = ""
      uri.fragment = uri.query = nil

      return uri.to_s
    rescue URI::Error => e
      url
    end
  end
end

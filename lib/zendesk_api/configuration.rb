module ZendeskAPI
  # Holds the configuration options for the client and connection
  class Configuration
    # @return [String] The basic auth username.
    attr_accessor :username

    # @return [String] The basic auth password.
    attr_accessor :password

    # @return [String] The basic auth token.
    attr_accessor :token

    # @return [String] The API url. Must be https unless {#allow_http} is set.
    attr_accessor :url

    # @return [Boolean] Whether to attempt to retry when rate-limited (http status: 429).
    attr_accessor :retry

    # @return [Boolean] Whether to raise error when rate-limited (http status: 429).
    attr_accessor :raise_error_when_rate_limited

    # @return [Logger] Logger to use when logging requests.
    attr_accessor :logger

    # @return [Hash] Client configurations (eg ssh config) to pass to Faraday
    attr_accessor :client_options

    # @return [Symbol] Faraday adapter
    attr_accessor :adapter

    # @return [Proc] Faraday adapter proc
    attr_accessor :adapter_proc

    # @return [Boolean] Whether to allow non-HTTPS connections for development purposes.
    attr_accessor :allow_http

    # Client ID and secret, together with the refresh token, are used to obtain a new access token, after the old expires
    attr_accessor :client_id, :client_secret

    # @return [String] OAuth2 access_token
    attr_accessor :access_token
    # @return [String] OAuth2 refresh token used to obtain a new access token after the old expires
    attr_accessor :refresh_token

    # @return [Integer] Time in seconds after the refreshed access token expires.
    # Value between 5 minutes and 2 days (300 and 172800)
    attr_accessor :access_token_expiration
    # @return [Integer] Time in seconds after the refresh token, generated after access token refreshing, expires.
    # Value between 7 and 90 days (604800 and 7776000)
    attr_accessor :refresh_token_expiration

    # @return [Proc] A lambda that handles the response when the refresh_token is used to obtain a new access_token.
    # This allows the access_token to be saved for re-use later.
    attr_accessor :refresh_tokens_callback
    # @return [Boolean] Whether to automatically refresh tokens when an unauthorized error happens for an OAuth request.
    # The unauthorized error is still raised so the request could be retried with tokens refreshed.
    attr_accessor :auto_refresh_tokens

    attr_accessor :url_based_access_token

    # Use this cache instead of default ZendeskAPI::LRUCache.new
    # - must respond to read/write/fetch e.g. ActiveSupport::Cache::MemoryStore.new)
    # - pass false to disable caching
    # @return [ZendeskAPI::LRUCache]
    attr_accessor :cache

    # @return [Boolean] Whether to use resource_cache or not
    attr_accessor :use_resource_cache

    # specify the server error codes in which you want a retry to be attempted
    attr_accessor :retry_codes

    # specify if you want a (network layer) exception to elicit a retry
    attr_accessor :retry_on_exception

    # specify if you want instrumentation to be used
    attr_accessor :instrumentation

    def initialize
      @client_options = {}
      @use_resource_cache = true

      self.cache = ZendeskAPI::LRUCache.new(1000)
    end

    # Sets accept and user_agent headers, and url.
    #
    # @return [Hash] Faraday-formatted hash of options.
    def options
      {
        headers: {
          accept: "application/json",
          accept_encoding: "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          user_agent: "ZendeskAPI Ruby #{ZendeskAPI::VERSION}"
        },
        request: {
          open_timeout: 10,
          timeout: 60
        },
        url: @url
      }.merge(client_options)
    end
  end
end

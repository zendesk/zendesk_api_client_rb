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

    # @return [String] OAuth2 access_token
    attr_accessor :access_token

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
        :headers => {
          :accept => "application/json",
          :accept_encoding => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          :user_agent => "ZendeskAPI Ruby #{ZendeskAPI::VERSION}"
        },
        :request => {
          :open_timeout => 10,
          :timeout => 60
        },
        :url => @url
      }.merge(client_options)
    end
  end
end

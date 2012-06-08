module ZendeskAPI
  class Configuration
    # @return [String] The basic auth username.
    attr_accessor :username
    # @return [String] The basic auth password.
    attr_accessor :password
    # @return [String] The API url. Must be https unless {#dont_enforce_https} is set.
    attr_accessor :url
    # @return [Boolean] Whether to attempt to retry when rate-limited (http status: 429).
    attr_accessor :retry
    # @return [Logger] Logger to use when logging requests.
    attr_accessor :logger
    # @return [Hash] Client configurations (eg ssh config) to pass to Faraday
    attr_accessor :client_options
    # @return [Symbol] Faraday adapter
    attr_accessor :adapter
    # @return [Boolean] Whether to allow non-HTTPS connections for development purposes.
    attr_accessor :dont_enforce_https

    def initialize
      @client_options = {}
    end

    # Sets accept and user_agent headers, and url.
    #
    # @return [Hash] Faraday-formatted hash of options.
    def options
      {
        :headers => {
          :accept => 'application/json',
          :accept_encoding => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          :user_agent => "ZendeskAPI API #{ZendeskAPI::VERSION}"
        },
        :url => @url
      }.merge(client_options)
    end
  end
end

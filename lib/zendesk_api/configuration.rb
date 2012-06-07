module ZendeskAPI
  # Raised if a block is not passed to {ZendeskAPI.configure} or if that configuration
  # does not then pass the constraints.
  class ConfigurationException < Exception; end

  class << self

    # Takes a block, yields a new {Configuration} instance, then returns a new {Client} instance.
    #
    #
    # Does basic configuration constraints:
    # * {Configuration#url} must be https unless {Configuration#dont_enforce_https} is set.
    #
    # @return [Client] {Client} instance with given configuration options
    def configure
      raise ConfigurationException.new("must pass block") unless block_given?

      client = ZendeskAPI::Client.new
      yield client.config

      if !client.config.dont_enforce_https && client.config.url !~ /^https/
        raise ConfigurationException.new('zendesk_api is ssl only; url must begin with https://')
      end

      client.config.retry = !!client.config.retry # nil -> false

      if client.config.logger.nil? || client.config.logger == true
        require 'logger'
        client.config.logger = Logger.new($stderr)
        client.config.logger.level = Logger::WARN
      end

      client
    end
  end

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

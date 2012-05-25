module Zendesk
  # Raised if a block is not passed to {Zendesk.configure} or if that configuration
  # does not then pass the constraints.
  class ConfigurationException < Exception; end

  class << self

    # Takes a block, yields a new {Configuration} instance, then returns a new {Client} instance.
    #
    #
    # Does basic configuration constraints:
    # * Configuration#url must be https unless it is localhost of 127.0.0.1
    #
    # @return [Client] {Client} instance with given configuration options
    def configure
      raise ConfigurationException.new("must pass block") unless block_given?

      client = Zendesk::Client.new
      yield client.config

      if client.config.url !~ /^https/ && client.config.url !~ /(127.0.0.1)|(localhost)/
        raise ConfigurationException.new('zendesk api is ssl only; url must begin with https://')
      end

      # Turns nil -> false, does nothing to true
      client.config.retry = !!client.config.retry
      client.config.log = !!client.config.log

      client
    end
  end

  class Configuration
    # @return [String] The basic auth username.
    attr_accessor :username
    # @return [String] The basic auth password.
    attr_accessor :password
    # @return [String] The API url. Must be https if not localhost or 127.0.0.1
    attr_accessor :url
    # @return [String] For behalf of the end user.
    attr_accessor :on_behalf_of
    # @return [Boolean] Whether to attempt to retry when rate-limited (http status: 429).
    attr_accessor :retry
    # @return [Boolean] Whether to log requests to STDOUT.
    attr_accessor :log
    # @return [Hash] Client configurations (eg ssh config) to pass to Faraday
    attr_accessor :client_options
    # @return [Symbol] Faraday adapter
    attr_accessor :adapter

    def initialize
      @client_options = {}
    end

    # Sets accept and user_agent headers, and url.
    #
    # @return [Hash] Faraday-formatted hash of options.
    def options
      { :headers => {
          :accept => 'application/json',
          :accept_encoding => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          :user_agent => "Zendesk API #{Zendesk::VERSION}"
        },
        :url => @url
      }.merge(client_options).tap do |hsh|
        hsh[:headers][:x_on_behalf_of] = on_behalf_of if on_behalf_of
      end
    end
  end
end

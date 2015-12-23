require 'logger'

module ZendeskAPI
  # Holds the configuration options for the client and connection
  class Configuration < Struct.new(
    :username, :password, :token, :url, :retry,
    :logger, :client_options, :adapter,
    :access_token, :url_based_access_token, :cache
  )
    def initialize(options = {})
      super()

      options.each {|k, v| self[k] = v}

      self.client_options ||= {}
      self.cache ||= ZendeskAPI::LRUCache.new(1000)
      self.adapter ||= Faraday.default_adapter

      unless logger
        self.logger = Logger.new(STDERR)
        self.logger.level = Logger::WARN
      end
    end

    def logger=(logger)
      return if logger == true || logger.nil?

      super
    end

    def username_with_token
      if username.end_with?('/token')
        username
      else
        username + '/token'
      end
    end

    def token_auth?
      token && !password
    end

    def check_values!
      if url !~ /^https/
        raise ArgumentError, "zendesk_api is ssl only; url must begin with https://"
      end
    end

    # Sets accept and user_agent headers, and url.
    #
    # @return [Hash] Faraday-formatted hash of options.
    def options
      {
        headers: {
          accept: 'application/json',
          accept_encoding: 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          user_agent: "ZendeskAPI Ruby #{ZendeskAPI::VERSION}"
        },
        request: {
          open_timeout: 10
        },
        url: url
      }.merge(client_options)
    end
  end
end

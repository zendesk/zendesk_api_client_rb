module Zendesk
  class ConfigurationException < Exception; end

  class << self
    def configure
      raise ConfigurationException.new("must pass block") unless block_given?

      client = Zendesk::Client.new
      yield client.config

      if client.config.url !~ /https/ && client.config.url !~ /(127.0.0.1)|(localhost)/
        raise ConfigurationException.new('zendesk api is ssl only; url must begin with https://')
      end

      # Turns nil -> false, does nothing to true
      client.config.retry = !!client.config.retry
      client.config.log = !!client.config.log

      client
    end
  end

  class Configuration
    attr_accessor :username, :password, :url, :retry, :log

    def options
      { 
        :headers => { 
          :accept => 'application/json',
          :user_agent => "Zendesk API #{Zendesk::VERSION}"
        },
        :url => @url
      }
    end
  end
end

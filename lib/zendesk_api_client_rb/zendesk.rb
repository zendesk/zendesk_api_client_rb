require 'faraday'
require 'faraday_middleware'

require 'zendesk_api_client_rb/collection'

module Zendesk
  class ConfigurationException < Exception; end

  class << self
    def configure
      client = Zendesk::Client.new
      yield client.config

      if client.config.url !~ /https/
        raise ConfigurationException.new('zendesk api is ssl only; url must begin with https://')
      end

      client.config.format ||= :json

      unless [:json].include?(client.config.format.to_sym)
        raise ConfigurationException.new('zendesk api only supports json format') 
      end

      client
    end
  end

  class Configuration
    attr_accessor :username, :password, :url, :format

    def options
      { 
        :headers => { 
          :accept => 'application/json',
          :user_agent => "Zendesk API #{ZendeskApiClientRb::VERSION}"
        },
        :url => @url
      }
    end
  end

  class Client
    class << self
      def collection(resource)
        class_eval <<-END
        def #{resource}(opts = {})
          response = connection.get("#{resource}.\#{config.format}") do |req|
            req.params = opts
          end

          return Zendesk::Collection.new(self, "#{resource}", response.body)
        end
        END
      end
    end

    attr_reader :config
    collection :tickets

    def initialize
      @config = Zendesk::Configuration.new
      @connection = false
    end

    def connection
      unless @connection
        @connection = Faraday.new(config.options) do |builder|
          builder.use Faraday::Adapter::NetHttp
          builder.use Faraday::Response::Logger

          if config.format == :json
            builder.use FaradayMiddleware::ParseJson
          end
        end
        @connection.basic_auth config.username, config.password
      end

      @connection
    end
  end
end

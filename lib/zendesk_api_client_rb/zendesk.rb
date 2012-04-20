require 'faraday'
require 'faraday_middleware'

require 'zendesk_api_client_rb/collection'
require 'zendesk_api_client_rb/retry_middleware'
require 'zendesk_api_client_rb/error_middleware'

module Zendesk
  class ConfigurationException < Exception; end

  class << self
    def configure
      client = Zendesk::Client.new
      yield client.config

      if client.config.url !~ /https/ && client.config.url !~ /(127.0.0.1)|(localhost)/
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
      def collection(resource, opts = {})
        class_eval <<-END
        def #{opts[:method] || resource}(opts = {})
          response = connection.get("#{opts[:path] || resource}.\#{config.format}") do |req|
            req.params = opts
          end

          if response.status == 200
            Zendesk::Collection.new(self, "#{resource}", response.body)
          else
            response.body
          end
        end
        END
      end
    end

    attr_reader :config
    collection :tickets
    collection :tickets, :path => 'tickets/recent', :method => :recent_tickets
    collection :ticket_fields
    collection :users
    collection :macros, :path => 'macros/active'
    collection :views
    collection :views, :path => 'views/active', :method => :active_views
    collection :custom_roles
    collection :bookmarks
    collection :activities
    collection :groups
    collection :groups, :path => 'groups/assignable', :method => :assignable_groups
    collection :group_memberships
    collection :locales
    collection :settings, :path => 'account/settings'
    collection :mobile_devices
    collection :satisfaction_ratings
    collection :satisfaction_ratings, :path => 'satisfaction_ratings/received', :method => :received_satisfaction_ratings
    collection :organizations
    #collection :uploads
    collection :categories
    collection :forums
    collection :topics
    collection :topic_comments
    collection :topic_subscriptions
    collection :forum_subscriptions

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
          
          # Should always be first in the stack
          builder.use Zendesk::Request::RetryMiddleware
          builder.use Zendesk::Request::ErrorMiddleware
        end
        @connection.basic_auth config.username, config.password
      end

      @connection
    end
  end
end

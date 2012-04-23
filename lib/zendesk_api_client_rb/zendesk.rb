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

      # Turns nil -> false, does nothing to true
      client.config.retry = !!client.config.retry

      client
    end
  end

  class Configuration
    attr_accessor :username, :password, :url, :retry

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
        resource = resource.to_s
        method = opts.delete(:method) || resource

        define_method method do |*args|
          return instance_variable_get("@#{method}") if !opts.delete(:reload) && instance_variable_defined?("@#{method}")
          options = args.last.is_a?(Hash) ? args.pop : {}
          instance_variable_set("@#{method}", Zendesk::Collection.new(self, resource, [resource], opts.merge(options)))
        end
      end
    end

    attr_reader :config
    collection :tickets
    collection :tickets, :path => 'tickets/recent', :method => :recent_tickets
    collection :ticket_fields
    collection :users
    collection :users, :path => 'users/search', :method => :search_users
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
    collection :categories
    collection :forums
    collection :topics
    collection :topics, :path => 'topics/show_many', :method => :show_many, :verb => :post 
    collection :topic_comments
    collection :topic_subscriptions
    collection :forum_subscriptions

    # Play the playlist
    # id can be a view id or 'incoming'
    def play(id)
      Zendesk::Playlist.new(self, id)
    end

    def initialize
      @config = Zendesk::Configuration.new
      @connection = false
    end

    def connection
      unless @connection
        @connection = Faraday.new(config.options) do |builder|
          builder.use Faraday::Adapter::NetHttp
          builder.use Faraday::Response::Logger

          builder.use FaradayMiddleware::ParseJson
          
          # Should always be first in the stack
          if config.retry
            builder.use Zendesk::Request::RetryMiddleware
          end

          builder.use Zendesk::Request::ErrorMiddleware
        end
        @connection.basic_auth config.username, config.password
      end

      @connection
    end
  end
end

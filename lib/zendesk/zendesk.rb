require 'faraday'
require 'faraday_middleware'

require 'zendesk/configuration'
require 'zendesk/collection'
require 'zendesk/middleware/retry_middleware'

module Zendesk
  class Client
    class << self
      # Creates a top-level reference to resource.
      # Options are: method (defaults to resource, change the created method name).
      # Any other options are passed to the collection creation..
      # @param [Symbol] resource The resource to reference
      # @param [Hash] opts Optional options
      def collection(resource, opts = {})
        resource = resource.to_s
        method = opts.delete(:method) || resource

        define_method method do |*args|
          options = args.last.is_a?(Hash) ? args.pop : {}
          return instance_variable_get("@#{method}") if !options.delete(:reload) && instance_variable_defined?("@#{method}")
          instance_variable_set("@#{method}", Zendesk::Collection.new(self, resource, [resource], opts.merge(options)))
        end
      end
    end

    # @return [Configuration] Config instance
    attr_reader :config

    # @group Resources

    # @method tickets(opts = {})
    collection :tickets
    # @method recent_tickets(opts = {})
    collection :tickets, :path => 'tickets/recent', :method => :recent_tickets
    # @method ticket_fields(opts = {})
    collection :ticket_fields
    # @method users(opts = {})
    collection :users
    # @method search_users(opts = {})
    collection :users, :path => 'users/search', :method => :search_users
    # @method macros(opts = {})
    collection :macros, :path => 'macros/active'
    # @method views(opts = {})
    collection :views
    # @method active_views(opts = {})
    collection :views, :path => 'views/active', :method => :active_views
    # @method custom_roles(opts = {})
    collection :custom_roles
    # @method bookmarks(opts = {})
    collection :bookmarks
    # @method activities(opts = {})
    collection :activities
    # @method groups(opts = {})
    collection :groups
    # @method assignable_groups(opts = {})
    collection :groups, :path => 'groups/assignable', :method => :assignable_groups
    # @method group_memberships(opts = {})
    collection :group_memberships
    # @method locales(opts = {})
    collection :locales
    # @method settings(opts = {})
    collection :settings, :path => 'account/settings'
    # @method mobile_devices(opts = {})
    collection :mobile_devices
    # @method satisfaction_ratings(opts = {})
    collection :satisfaction_ratings
    # @method received_satisfaction_ratings(opts = {})
    collection :satisfaction_ratings, :path => 'satisfaction_ratings/received', :method => :received_satisfaction_ratings
    # @method organizations(opts = {})
    collection :organizations
    # @method categories(opts = {})
    collection :categories
    # @method forums(opts = {})
    collection :forums
    # @method topics(opts = {})
    collection :topics
    # @method show_many(opts = {})
    collection :topics, :path => 'topics/show_many', :method => :show_many, :verb => :post 
    # @method topic_comments(opts = {})
    collection :topic_comments
    # @method topic_subscriptions(opts = {})
    collection :topic_subscriptions
    # @method forum_subscriptions(opts = {})
    collection :forum_subscriptions

    # @endgroup

    # Plays a view playlist.
    # @param [String/Number] id View id or 'incoming'
    def play(id)
      Zendesk::Playlist.new(self, id)
    end

    # Creates a new Client instance with no configuration options and no connection.
    def initialize
      @config = Zendesk::Configuration.new
      @connection = false
    end

    # Creates a connection if there is none, otherwise returns the existing connection.
    #
    # Uses middleware according to configuration options.
    #
    # Request logger if log is true
    # 
    # Retry middleware if retry is true
    def connection
      return @connection if @connection

      @connection = Faraday.new(config.options) do |builder|
        builder.response :logger if config.log

        builder.request :json
        builder.response :json


        builder.use Faraday::Response::RaiseError
        # Should always be first in the stack
        builder.use Zendesk::Request::RetryMiddleware if config.retry
        builder.adapter Faraday.default_adapter
      end
      @connection.tap {|c| c.basic_auth(config.username, config.password)}
    end
  end
end

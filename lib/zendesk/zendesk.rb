require 'faraday'
require 'faraday_middleware'

require 'zendesk/version'
require 'zendesk/rescue'
require 'zendesk/configuration'
require 'zendesk/collection'
require 'zendesk/middleware/retry_middleware'
require 'zendesk/middleware/callback_middleware'
require 'zendesk/middleware/upload_middleware'

module Zendesk
  class Client
    extend Rescue

    # @return [Configuration] Config instance
    attr_reader :config
    # @return [Array] Custom response callbacks
    attr_reader :callbacks

    # Handles resources such as 'tickets'. Any options are passed to the underlying collection, except reload which disregards
    # memoization and creates a new Collection instance.
    # @param [Hash] opts Custom options passed to underlying collection
    # @return [Collection] Collection instance for resource
    def method_missing(method, *args, &blk)
      method = method.to_s
      options = args.last.is_a?(Hash) ? args.pop : {}
      return instance_variable_get("@#{method}") if !options.delete(:reload) && instance_variable_defined?("@#{method}")
      instance_variable_set("@#{method}", Zendesk::Collection.new(self, Zendesk.get_class(method.singular), options))
    end

    # Plays a view playlist.
    # @param [String/Number] id View id or 'incoming'
    def play(id)
      Zendesk::Playlist.new(self, id)
    end

    # Returns the current user (aka me)
    # @return [Zendesk::User] Current user or nil
    def current_user(reload = false)
      return @current_user if @current_user && !reload
      @current_user = users.find(:id => 'me')
    end

    def current_account(reload = false)
      return @current_account if @current_account && !reload
      @current_account = Hashie::Mash.new(connection.get('account/resolve').body)
    end

    rescue_client_error :current_account

    # Returns the current locale
    def current_locale(reload = false)
      return @locale if @locale && !reload
      @locale = locales.find(:id => 'current')
    end

    # Creates a new Client instance with no configuration options and no connection.
    def initialize
      @config = Zendesk::Configuration.new
      @connection = false
      @callbacks = []

      insert_callback do |env|
        puts "WARNING: #{env[:response_headers]["X-Zendesk-API-Warn"]}" if env[:response_headers]["X-Zendesk-API-Warn"]
      end
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
        builder.use Zendesk::Request::UploadMiddleware
        builder.use Faraday::Response::RaiseError
        builder.use Zendesk::Response::CallbackMiddleware, self
        builder.response :logger if config.log

        builder.request :multipart
        builder.request :json
        builder.response :json

        # Should always be first in the stack
        builder.use Zendesk::Request::RetryMiddleware if config.retry
        builder.adapter Faraday.default_adapter
      end
      @connection.tap {|c| c.basic_auth(config.username, config.password)}
    end

    # Pushes a callback onto the stack. Callbacks are executed on responses, last in the Faraday middleware stack.
    # @param [Proc] blk The block to execute. Takes one parameter, env.
    def insert_callback(&blk)
      @callbacks << blk
    end
  end
end

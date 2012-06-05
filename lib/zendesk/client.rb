require 'faraday'
require 'faraday_middleware'

require 'zendesk/version'
require 'zendesk/rescue'
require 'zendesk/configuration'
require 'zendesk/collection'
require 'zendesk/middleware/request/retry'
require 'zendesk/middleware/request/upload'
require 'zendesk/middleware/response/callback'
require 'zendesk/middleware/response/deflate'
require 'zendesk/middleware/response/gzip'
require 'zendesk/middleware/response/parse_iso_dates'

module Zendesk
  class Client
    extend Rescue

    # @return [Configuration] Config instance
    attr_reader :config
    # @return [Array] Custom response callbacks
    attr_reader :callbacks

    # Handles resources such as 'tickets'. Any options are passed to the underlying collection, except reload which disregards
    # memoization and creates a new Collection instance.
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

      if logger = config.logger
        insert_callback do |env|
          if warning = env[:response_headers]["X-Zendesk-API-Warn"]
            logger.warn "WARNING: #{warning}"
          end
        end
      end
    end

    # Creates a connection if there is none, otherwise returns the existing connection.
    #
    # Uses middleware according to configuration options.
    #
    # Request logger if logger is not nil
    # 
    # Retry middleware if retry is true
    def connection
      return @connection if @connection

      @connection = Faraday.new(config.options) do |builder|
        # response
        builder.use Faraday::Response::RaiseError
        builder.use Zendesk::Middleware::Response::Callback, self
        builder.use Faraday::Response::Logger, config.logger if config.logger
        builder.use Zendesk::Middleware::Response::ParseIsoDates
        builder.response :json
        builder.use Zendesk::Middleware::Response::Gzip
        builder.use Zendesk::Middleware::Response::Deflate

        # request
        builder.use Zendesk::Middleware::Request::Upload
        builder.request :multipart
        builder.request :json
        builder.use Zendesk::Middleware::Request::Retry, :logger => config.logger if config.retry # Should always be first in the stack

        builder.adapter *config.adapter || Faraday.default_adapter
      end
      @connection.tap {|c| c.basic_auth(config.username, config.password)}
    end

    # Pushes a callback onto the stack. Callbacks are executed on responses, last in the Faraday middleware stack.
    # @param [Proc] blk The block to execute. Takes one parameter, env.
    def insert_callback(&blk)
      @callbacks << blk
    end

    # show a nice warning for people using the old style api
    def self.check_deprecated_namespace_usage(attributes, name)
      raise "un-nest '#{name}' from the attributes" if attributes[name].is_a?(Hash)
    end
  end
end

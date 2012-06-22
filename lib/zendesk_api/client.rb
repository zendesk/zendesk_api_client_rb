require 'faraday'
require 'faraday_middleware'

require 'zendesk_api/version'
require 'zendesk_api/rescue'
require 'zendesk_api/configuration'
require 'zendesk_api/collection'
require 'zendesk_api/lru_cache'
require 'zendesk_api/middleware/request/etag_cache'
require 'zendesk_api/middleware/request/retry'
require 'zendesk_api/middleware/request/upload'
require 'zendesk_api/middleware/response/callback'
require 'zendesk_api/middleware/response/deflate'
require 'zendesk_api/middleware/response/gzip'
require 'zendesk_api/middleware/response/parse_iso_dates'

module ZendeskAPI
  class Client
    include Rescue

    # @return [Configuration] Config instance
    attr_reader :config
    # @return [Array] Custom response callbacks
    attr_reader :callbacks

    # Handles resources such as 'tickets'. Any options are passed to the underlying collection, except reload which disregards
    # memoization and creates a new Collection instance.
    # @return [Collection] Collection instance for resource
    def method_missing(method, *args, &block)
      method = method.to_s
      options = args.last.is_a?(Hash) ? args.pop : {}
      return instance_variable_get("@#{method}") if !options.delete(:reload) && instance_variable_defined?("@#{method}")
      instance_variable_set("@#{method}", ZendeskAPI::Collection.new(self, ZendeskAPI.get_class(method.singular), options))
    end

    # Plays a view playlist.
    # @param [String/Number] id View id or 'incoming'
    def play(id)
      ZendeskAPI::Playlist.new(self, id)
    end

    # Returns the current user (aka me)
    # @return [ZendeskAPI::User] Current user or nil
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

    # Creates a new {Client} instance and yields {#config}.
    #
    # Requires a block to be given.
    #
    # Does basic configuration constraints:
    # * {Configuration#url} must be https unless {Configuration#allow_http} is set.
    def initialize
      raise ArgumentError, "block not given" unless block_given?

      @config = ZendeskAPI::Configuration.new
      yield config

      if !config.allow_http && config.url !~ /^https/
        raise ArgumentError, "zendesk_api is ssl only; url must begin with https://"
      end

      config.retry = !!config.retry # nil -> false

      if config.logger.nil? || config.logger == true
        require 'logger'
        config.logger = Logger.new($stderr)
        config.logger.level = Logger::WARN
      end

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
    # @returns [Faraday::Connection] Faraday connection for the client
    def connection
      @connection ||= build_connection
      return @connection
    end

    # Pushes a callback onto the stack. Callbacks are executed on responses, last in the Faraday middleware stack.
    # @param [Proc] block The block to execute. Takes one parameter, env.
    def insert_callback(&block)
      @callbacks << block
    end

    # show a nice warning for people using the old style api
    def self.check_deprecated_namespace_usage(attributes, name)
      raise "un-nest '#{name}' from the attributes" if attributes[name].is_a?(Hash)
    end

    protected

    # Called by {#connection} to build a connection. Can be overwritten in a
    # subclass to add additional middleware and make other configuration
    # changes.
    #
    # Uses middleware according to configuration options.
    #
    # Request logger if logger is not nil
    # 
    # Retry middleware if retry is true
    def build_connection
      Faraday.new(config.options) do |builder|
        # response
        builder.use Faraday::Request::BasicAuthentication, config.username, config.password
        builder.use Faraday::Response::RaiseError
        builder.use ZendeskAPI::Middleware::Response::Callback, self
        builder.use Faraday::Response::Logger, config.logger if config.logger
        builder.use ZendeskAPI::Middleware::Response::ParseIsoDates
        builder.response :json, :content_type => 'application/json'
        builder.use ZendeskAPI::Middleware::Response::Gzip
        builder.use ZendeskAPI::Middleware::Response::Deflate

        # request
        builder.use ZendeskAPI::Middleware::Request::EtagCache, :cache => config.cache
        builder.use ZendeskAPI::Middleware::Request::Upload
        builder.request :multipart
        builder.request :json
        builder.use ZendeskAPI::Middleware::Request::Retry, :logger => config.logger if config.retry # Should always be first in the stack

        builder.adapter *config.adapter || Faraday.default_adapter
      end
    end
  end
end

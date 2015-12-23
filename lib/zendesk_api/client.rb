require 'faraday'
require 'faraday_middleware'
require 'faraday-http-cache'

require 'zendesk_api/version'
require 'zendesk_api/sideloading'
require 'zendesk_api/configuration'
require 'zendesk_api/collection'

require 'zendesk_api/middleware/request/retry'
require 'zendesk_api/middleware/request/upload'
require 'zendesk_api/middleware/request/url_based_access_token'

require 'zendesk_api/middleware/response/callback'
require 'zendesk_api/middleware/response/sanitize_response'
require 'zendesk_api/middleware/response/parse_iso_dates'
require 'zendesk_api/middleware/response/raise_error'
require 'zendesk_api/middleware/response/logger'

require 'zendesk_api/delegator'

module ZendeskAPI
  # The top-level class that handles configuration and connection to the Zendesk API.
  # Can also be used as an accessor to resource collections.
  class Client
    GZIP_EXCEPTIONS = [:em_http, :httpclient]

    METHOD_TO_RESOURCE_LOOKUP = Hash.new do |h, k|
      @@resource_classes ||= begin
        subclasses_for = lambda do |klass|
          klass.subclasses.flat_map do |subclass|
            [subclass] + subclasses_for[subclass]
          end
        end

        subclasses_for[ZendeskAPI::Data].select(&:resource_name)
      end

      h[k] = @@resource_classes.find {|x| x.resource_name == k}
    end

    # @return [Configuration] Config instance
    attr_reader :config

    # Handles resources such as 'tickets'. Any options are passed to the underlying collection, except reload which disregards
    # memoization and creates a new Collection instance.
    # @return [Collection] Collection instance for resource
    def method_missing(method, *args, **options, &block)
      if klass = method_as_class(method)
        ZendeskAPI::Collection.new(self, klass, options)
      else
        super
      end
    end

    def respond_to?(method, *)
      !method_as_class(method).nil? || super
    end

    # Returns the current user (aka me)
    # @return [ZendeskAPI::User] Current user or nil
    def current_user(reload = false)
      return @current_user if @current_user && !reload
      @current_user = users.find(:id => 'me')
    end

    # Returns the current account
    # @return [Hash] The attributes of the current account or nil
    def current_account(reload = false)
      return @current_account if @current_account && !reload
      @current_account = Hashie::Mash.new(connection.get('account/resolve').body)
    end

    # Returns the current locale
    # @return [ZendeskAPI::Locale] Current locale or nil
    def current_locale(reload = false)
      return @locale if @locale && !reload
      @locale = locales.find(:id => 'current')
    end

    # Creates a new {Client} instance and yields {#config}.
    #
    # Requires a block to be given.
    def initialize(options = {})
      @config = ZendeskAPI::Configuration.new(options)

      yield config if block_given?

      config.check_values!
      add_warning_callback

      @resource_cache = {}
    end

    # Creates a connection if there is none, otherwise returns the existing connection.
    #
    # @return [Faraday::Connection] Faraday connection for the client
    def connection
      @connection ||= build_connection
    end

    # Pushes a callback onto the stack. Callbacks are executed on responses, last in the Faraday middleware stack.
    # @param [Proc] block The block to execute. Takes one parameter, env.
    def insert_callback(&block)
      config.callbacks << block
    end

    ZendeskAPI::DataNamespace.descendants.each do |namespace|
      define_method namespace.namespace do |*| # takes arguments, but doesn't do anything with them
        Delegator.new(self)
      end
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
        builder.use ZendeskAPI::Middleware::Response::RaiseError
        builder.use ZendeskAPI::Middleware::Response::Callback, config.callbacks

        if config.logger
          builder.use ZendeskAPI::Middleware::Response::Logger, config.logger
        end

        builder.use ZendeskAPI::Middleware::Response::ParseIsoDates
        builder.response :json, content_type: /\bjson\z/
        builder.use ZendeskAPI::Middleware::Response::SanitizeResponse

        unless GZIP_EXCEPTIONS.include?(config.adapter)
          builder.use :gzip
        end

        # request
        if config.access_token && !config.url_based_access_token
          builder.authorization('Bearer', config.access_token)
        elsif config.access_token
          builder.use ZendeskAPI::Middleware::Request::UrlBasedAccessToken, config.access_token
        elsif config.token_auth?
          builder.basic_auth(config.username_with_token, config.token)
        else
          builder.basic_auth(config.username, config.password)
        end

        if config.cache
          builder.use :http_cache, store: config.cache
        end

        builder.use ZendeskAPI::Middleware::Request::Upload
        builder.request :multipart
        builder.request :json

        if config.retry # Should always be first in the stack
          builder.use ZendeskAPI::Middleware::Request::Retry, logger: config.logger
        end

        builder.adapter *config.adapter
      end
    end

    private

    def method_as_class(method)
      METHOD_TO_RESOURCE_LOOKUP[method.to_s]
    end

    def add_warning_callback
      return unless logger = config.logger

      insert_callback do |env|
        if warning = env[:response_headers]["X-Zendesk-API-Warn"]
          logger.warn "WARNING: #{warning}"
        end
      end
    end
  end
end

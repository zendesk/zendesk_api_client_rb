require 'zendesk_api/version'
require 'zendesk_api/sideloading'
require 'zendesk_api/configuration'
require 'zendesk_api/collection'
require 'zendesk_api/lru_cache'
require 'zendesk_api/silent_mash'
require 'zendesk_api/middleware/request/etag_cache'
require 'zendesk_api/middleware/request/retry'
require 'zendesk_api/middleware/request/raise_rate_limited'
require 'zendesk_api/middleware/request/upload'
require 'zendesk_api/middleware/request/encode_json'
require 'zendesk_api/middleware/request/url_based_access_token'
require 'zendesk_api/middleware/response/callback'
require 'zendesk_api/middleware/response/deflate'
require 'zendesk_api/middleware/response/gzip'
require 'zendesk_api/middleware/response/sanitize_response'
require 'zendesk_api/middleware/response/parse_iso_dates'
require 'zendesk_api/middleware/response/parse_json'
require 'zendesk_api/middleware/response/raise_error'
require 'zendesk_api/middleware/response/logger'
require 'zendesk_api/delegator'

module ZendeskAPI
  # The top-level class that handles configuration and connection to the Zendesk API.
  # Can also be used as an accessor to resource collections.
  class Client
    GZIP_EXCEPTIONS = [:em_http, :httpclient, :httpx]

    # @return [Configuration] Config instance
    attr_reader :config
    # @return [Array] Custom response callbacks
    attr_reader :callbacks

    def ticket_fields_metadata
      @ticket_fields_metadata ||= []
    end

    # Handles resources such as 'tickets'. Any options are passed to the underlying collection, except reload which disregards
    # memoization and creates a new Collection instance.
    # @return [Collection] Collection instance for resource
    def method_missing(method, *args, &)
      method = method.to_s
      options = args.last.is_a?(Hash) ? args.pop : {}
      unless config.use_resource_cache
        resource_class = resource_class_for(method)
        raise "Resource for #{method} does not exist" unless resource_class
        return ZendeskAPI::Collection.new(self, resource_class, options)
      end

      @resource_cache[method] ||= { :class => nil, :cache => ZendeskAPI::LRUCache.new }
      if !options.delete(:reload) && (cached = @resource_cache[method][:cache].read(options.hash))
        cached
      else
        @resource_cache[method][:class] ||= resource_class_for(method)
        raise "Resource for #{method} does not exist" unless @resource_cache[method][:class]
        @resource_cache[method][:cache].write(options.hash, ZendeskAPI::Collection.new(self, @resource_cache[method][:class], options))
      end
    end

    def respond_to?(method, *args)
      cache = @resource_cache[method]
      !!(cache.to_h[:class] || resource_class_for(method) || super)
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
      @current_account = SilentMash.new(connection.get('account/resolve').body)
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
    #
    # Does basic configuration constraints:
    # * {Configuration#url} must be https unless {Configuration#allow_http} is set.
    def initialize
      raise ArgumentError, "block not given" unless block_given?

      @config = ZendeskAPI::Configuration.new
      yield config

      @callbacks = []
      @resource_cache = {}

      check_url

      config.retry = !!config.retry # nil -> false

      set_raise_error_when_rated_limited
      set_token_auth
      set_default_logger
      add_warning_callback
      load_ticket_fields_metadata if @config.load_ticket_fields_metadata
    end

    def load_ticket_fields_metadata
      @ticket_fields_metadata = []
      ticket_fields.all do |f|
        if f
          @ticket_fields_metadata << f
        end
      end
      @ticket_fields_metadata
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
      @callbacks << block
    end

    # show a nice warning for people using the old style api
    def self.check_deprecated_namespace_usage(attributes, name)
      if attributes[name].is_a?(Hash)
        raise "un-nest '#{name}' from the attributes"
      end
    end

    ZendeskAPI::DataNamespace.descendants.each do |namespace|
      delegator = ZendeskAPI::Helpers.snakecase_string(namespace.to_s.split("::").last)
      define_method delegator do |*| # takes arguments, but doesn't do anything with them
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
        builder.use ZendeskAPI::Middleware::Response::Callback, self
        builder.use ZendeskAPI::Middleware::Response::Logger, config.logger if config.logger
        builder.use ZendeskAPI::Middleware::Response::ParseIsoDates
        builder.use ZendeskAPI::Middleware::Response::ParseJson
        builder.use ZendeskAPI::Middleware::Response::SanitizeResponse
        adapter = config.adapter || Faraday.default_adapter

        unless GZIP_EXCEPTIONS.include?(adapter)
          builder.use ZendeskAPI::Middleware::Response::Gzip
          builder.use ZendeskAPI::Middleware::Response::Deflate
        end

        set_authentication(builder, config)

        if config.cache
          builder.use ZendeskAPI::Middleware::Request::EtagCache, :cache => config.cache
        end

        builder.use ZendeskAPI::Middleware::Request::Upload
        builder.request :multipart
        builder.use ZendeskAPI::Middleware::Request::EncodeJson

        # Should always be first in the stack
        if config.retry
          builder.use ZendeskAPI::Middleware::Request::Retry,
                      :logger => config.logger,
                      :retry_codes => config.retry_codes,
                      :retry_on_exception => config.retry_on_exception
        end
        if config.raise_error_when_rate_limited
          builder.use ZendeskAPI::Middleware::Request::RaiseRateLimited, :logger => config.logger
        end

        builder.adapter(*adapter, &config.adapter_proc)
      end
    end

    private

    def resource_class_for(method)
      resource_name = ZendeskAPI::Helpers.modulize_string(Inflection.singular(method.to_s.gsub(/\W/, '')))
      ZendeskAPI::Association.class_from_namespace(resource_name)
    end

    def check_url
      if !config.allow_http && !config.url.start_with?('https://')
        raise ArgumentError, "zendesk_api is ssl only; url must begin with https://"
      end
    end

    def set_raise_error_when_rated_limited
      config.raise_error_when_rate_limited = if config.retry
        false
      else
        !!config.raise_error_when_rate_limited
      end
    end

    def set_token_auth
      return if config.password || config.token.nil?

      if config.username.nil?
        raise ArgumentError, "you need to provide a username when using API token auth"
      else
        config.password = config.token
        config.username += "/token" unless config.username.end_with?("/token")
      end
    end

    def set_default_logger
      if config.logger.nil? || config.logger == true
        require 'logger'
        config.logger = Logger.new($stderr)
        config.logger.level = Logger::WARN
      end
    end

    def add_warning_callback
      return unless logger = config.logger

      insert_callback do |env|
        if warning = env[:response_headers]["X-Zendesk-API-Warn"]
          logger.warn "WARNING: #{warning}"
        end
      end
    end

    # See https://lostisland.github.io/faraday/middleware/authentication
    def set_authentication(builder, config)
      if config.access_token && !config.url_based_access_token
        builder.request :authorization, "Bearer", config.access_token
      elsif config.access_token
        builder.use ZendeskAPI::Middleware::Request::UrlBasedAccessToken, config.access_token
      else
        builder.request :authorization, :basic, config.username, config.password
      end
    end
  end
end

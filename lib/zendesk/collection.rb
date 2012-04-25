require 'zendesk/parameter_whitelist'
require 'zendesk/resource'
require 'zendesk/resources/misc'
require 'zendesk/resources/ticket'
require 'zendesk/resources/forum'
require 'zendesk/resources/user'
require 'zendesk/resources/playlist'

module Zendesk
  # Represents a collection of resources. Lazily loaded, resources aren't
  # actually fetched until explicitly needed (e.g. #each, {#fetch}).
  class Collection
    # @return [Number] The total number of resources server-side (disregarding pagination).
    attr_reader :count

    # Creates a new Collection instance. Does not fetch resources.
    # Additional options are: verb (default: GET), path (default: resource param), page, per_page.
    # @param [Client] client The {Client} to use.
    # @param [String] resource The resource being collected.
    # @param [Array] path The path in array form that is sent to resources. (Note: not the query path)
    # @param [Hash] options Any additional options to be passed in.
    def initialize(client, resource, path = [], options = {})
      @client, @resource = client, resource
      @options = options
      @path = path

      @verb = @options.delete(:verb)
      @query_path = @options.delete(:path)

      @resource_class = Zendesk.get_class(resource.singular)
    end

    # @return [String] The path to fetch resources.
    def path
      @path.join("/")
    end

    # Passes arguments and the proper path to the resource class method.
    # @param [Hash] attributes Attributes to pass to Create#create
    def create(attributes = {})
      @resource_class.create(@client, attributes, path)
    end

    # (see #create)
    def find(id, opts = {})
      @resource_class.find(@client, id, opts.merge(:path => path))
    end

    # (see #create)
    def destroy(id)
      @resource_class.destroy(@client, id, path)
    end

    # Changes the per_page option. Returns self, so it can be chained. No execution.
    # @return [Collection] self
    def per_page(count)
      @options["per_page"] = count
      self
    end

    # Changes the page option. Returns self, so it can be chained. No execution.
    # @return [Collection] self
    def page(number)
      @options["page"] = number
      self
    end

    # Executes actual GET from API and loads resources into proper class.
    # @param [Boolean] reload Whether to disregard cache
    def fetch(reload = false)
      return @resources if @resources && !reload

      response = @client.connection.send(@verb || "get", @query ? @query : "#{@query_path || @resource}.json") do |req|
        req.params.merge!(@options.delete_if {|k, v| v.nil?})
      end

      @resources = response.body[@resource].map do |res|
        @resource_class.new(@client, { @resource_class.singular_resource_name => res }, @path.dup)
      end

      @count = (response.body["count"] || @resources.size).to_i
      @next_page, @prev_page = response.body["next_page"], response.body["previous_page"]

      self
    rescue Faraday::Error::ClientError => e
      []
    end

    # Alias for fetch(false)
    def to_a
      fetch
    end

    # Find the next page. Does one of three things: 
    # * If there is already a page number in the options hash, it increases it and invalidates the cache, returning the new page number.
    # * If there is a next_page url cached, it executes a fetch on that url and returns the results.
    # * Otherwise, returns an empty array.
    def next
      if @options["page"]
        clear
        @options["page"] += 1
      elsif @next_page
        @query = @next_page
        fetch(true).tap { @query = nil }
      else
        []
      end
    end

    # Find the previous page. Does one of three things: 
    # * If there is already a page number in the options hash, it increases it and invalidates the cache, returning the new page number.
    # * If there is a prev_page url cached, it executes a fetch on that url and returns the results.
    # * Otherwise, returns an empty array.
    def prev
      if @options["page"] && @options["page"] > 1 
        clear
        @options["page"] -= 1
      elsif @prev_page
        @query = @prev_page
        fetch(true).tap { @query = nil }
      else
        []
      end
    end

    # Clears all cached resources and associated values.
    def clear
      @resources = nil
      @count = nil
      @next_page = nil
      @prev_page = nil
    end

    # Sends methods to underlying array of resources.
    def method_missing(*args, &blk)
      to_a.send(*args, &blk)
    end

    def to_s
      if @resources
        @resources.inspect
      else
        orig_inspect
      end
    end
    alias :orig_inspect :inspect
    alias :inspect :to_s
  end
end

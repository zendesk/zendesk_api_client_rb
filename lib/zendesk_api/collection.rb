require 'zendesk_api/resource'
require 'zendesk_api/resources/misc'
require 'zendesk_api/resources/ticket'
require 'zendesk_api/resources/user'
require 'zendesk_api/resources/playlist'

module ZendeskAPI
  # Represents a collection of resources. Lazily loaded, resources aren't
  # actually fetched until explicitly needed (e.g. #each, {#fetch}).
  class Collection
    SPECIALLY_JOINED_PARAMS = [:include, :ids, :only]

    include Rescue

    # @return [ZendeskAPI::Association] The class association
    attr_reader :association

    # Creates a new Collection instance. Does not fetch resources.
    # Additional options are: verb (default: GET), path (default: resource param), page, per_page.
    # @param [Client] client The {Client} to use.
    # @param [String] resource The resource being collected.
    # @param [Hash] options Any additional options to be passed in.
    def initialize(client, resource, options = {})
      @client, @resource = client, resource.resource_name
      @options = Hashie::Mash.new(options)

      @verb = @options.delete(:verb)
      @collection_path = @options.delete(:collection_path)

      association_options = { :path => @options.delete(:path) }
      association_options[:path] ||= @collection_path.join("/") if @collection_path
      @association = @options.delete(:association) || Association.new(association_options.merge(:class => resource))

      # some params use comma-joined strings instead of query-based arrays for multiple values
      @options.each do |k, v|
        if SPECIALLY_JOINED_PARAMS.include?(k.to_sym) && v.is_a?(Array)
          @options[k] = v.join(',')
        end
      end

      @collection_path ||= [@resource]
      @resource_class = resource
      @fetchable = true

      # Used for Attachments, TicketComment
      if @resource_class.superclass == ZendeskAPI::Data
        @resources = []
        @fetchable = false
      end
    end

    # Passes arguments and the proper path to the resource class method.
    # @param [Hash] attributes Attributes to pass to Create#create
    def create(attributes = {})
      attributes.merge!(:association => @association)
      @resource_class.create(@client, @options.merge(attributes))
    end

    # (see #create)
    def find(opts = {})
      opts.merge!(:association => @association)
      @resource_class.find(@client, @options.merge(opts))
    end

    # (see #create)
    def update(opts = {})
      opts.merge!(:association => @association)
      @resource_class.update(@client, @options.merge(opts))
    end

    # (see #create)
    def destroy(opts = {})
      opts.merge!(:association => association)
      @resource_class.destroy(@client, @options.merge(opts))
    end

    # @return [Number] The total number of resources server-side (disregarding pagination).
    def count
      fetch
      @count
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

    # Saves all newly created resources stored in this collection.
    # @return [Collection] self
    def save
      if @resources
        @resources.map! do |item|
          unless !item.respond_to?(:save) || item.changes.empty?
            item.save
          end

          item
        end
      end

      self
    end

    def <<(item)
      fetch
      if item.is_a?(Resource)
        if item.is_a?(@resource_class)
          @resources << item
        else
          raise "this collection is for #{@resource_class}"
        end
      else
        item.merge!(:association => @association) if item.is_a?(Hash)
        @resources << @resource_class.new(@client, item)
      end
    end

    def path
      @association.generate_path(:with_parent => true)
    end

    # Executes actual GET from API and loads resources into proper class.
    # @param [Boolean] reload Whether to disregard cache
    def fetch(reload = false)
      return @resources if @resources && (!@fetchable || !reload)
      if association && association.options.parent && association.options.parent.new_record?
        return @resources = []
      end

      if @query
        path = @query
        @query = nil
      else
        path = self.path
      end

      response = @client.connection.send(@verb || "get", path) do |req|
        req.params.merge!(@options.delete_if {|k, v| v.nil?})
      end

      results = response.body[@resource_class.model_key] || response.body["results"]
      @resources = results.map { |res| @resource_class.new(@client, res) }

      @count = (response.body["count"] || @resources.size).to_i
      @next_page, @prev_page = response.body["next_page"], response.body["previous_page"]

      @resources
    end

    rescue_client_error :fetch, :with => lambda { Array.new }

    # Alias for fetch(false)
    def to_a
      fetch
    end

    def replace(collection)
      raise "this collection is for #{@resource_class}" if collection.any?{|r| !r.is_a?(@resource_class) }
      @resources = collection
    end

    # Find the next page. Does one of three things: 
    # * If there is already a page number in the options hash, it increases it and invalidates the cache, returning the new page number.
    # * If there is a next_page url cached, it executes a fetch on that url and returns the results.
    # * Otherwise, returns an empty array.
    def next
      if @options["page"]
        clear_cache
        @options["page"] += 1
      elsif @next_page
        @query = @next_page
        fetch(true)
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
        clear_cache
        @options["page"] -= 1
      elsif @prev_page
        @query = @prev_page
        fetch(true)
      else
        []
      end
    end

    # Clears all cached resources and associated values.
    def clear_cache
      @resources = nil
      @count = nil
      @next_page = nil
      @prev_page = nil
    end

    def to_ary; nil; end

    # Sends methods to underlying array of resources.
    def method_missing(name, *args, &block)
      methods = @resource_class.singleton_methods(false).map(&:to_sym)

      if methods.include?(name)
        @resource_class.send(name, @client, *args, &block)
      elsif Array.new.respond_to?(name)
        to_a.send(name, *args, &block)
      else
        opts = args.last.is_a?(Hash) ? args.last : {}
        opts.merge!(:collection_path => @collection_path.dup.push(name))
        self.class.new(@client, @resource_class, @options.merge(opts))
      end
    end

    alias :orig_to_s :to_s
    def to_s
      if @resources
        @resources.inspect
      else
        orig_to_s
      end
    end
  end
end

require 'facets/string/camelcase'
require 'facets/string/snakecase'


require 'zendesk/inflection'
require 'zendesk/parameter_whitelist'
require 'zendesk/resource'
require 'zendesk/resources/misc'
require 'zendesk/resources/ticket'
require 'zendesk/resources/forum'
require 'zendesk/resources/user'
require 'zendesk/resources/playlist'

module Zendesk
  class Collection
    attr_reader :count, :path
    def initialize(client, resource, path = [], options = {})
      @client, @resource = client, resource
      @options = options
      @path = path

      @verb = @options.delete(:verb)
      @query_path = @options.delete(:path)

      @resource_class = Zendesk.const_get(resource.singular.upper_camelcase)
    end

    def path
      @path.join("/")
    end

    def create(attributes = {})
      @resource_class.create(@client, attributes, path)
    end

    def find(id, opts = {})
      @resource_class.find(@client, id, opts.merge(:path => path))
    end

    def destroy(id)
      @resource_class.destroy(@client, id, path)
    end

    def per_page(count)
      @options["per_page"] = count
      self
    end

    def page(number)
      @options["page"] = number
      self
    end

    def fetch(reload = false)
      return @resources if @resources && !reload

      response = @client.connection.send(@verb || "get", @query ? @query : "#{@query_path || @resource}.json") do |req|
        req.params.merge!(@options.delete_if {|k, v| v.nil?})
      end

      if response.status == 200
        @resources = response.body[@resource].map do |res|
          @resource_class.new(@client, { @resource_class.singular_resource_name => res }, @path.dup)
        end

        @count = (response.body["count"] || @resources.size).to_i
        @next_page, @prev_page = response.body["next_page"], response.body["previous_page"]

        @resources
      else
        []
      end
    end

    # Depends on what users want
    def next
      if @options["page"]
        @resources = nil
        @options["page"] += 1
      elsif @next_page
        @query = @next_page
        fetch(true).tap { @query = nil }
      else
        []
      end
    end

    def prev
      if @options["page"] && @options["page"] > 1 
        @resources = nil
        @options["page"] -= 1
      elsif @prev_page
        @query = @prev_page
        fetch(true).tap { @query = nil }
      else
        []
      end
    end

    def to_a
      fetch
    end

    def clear
      @resources = nil
      @count = nil
      @next_page = nil
      @prev_page = nil
    end

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

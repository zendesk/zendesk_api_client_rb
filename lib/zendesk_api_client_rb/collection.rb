require 'facets/string/camelcase'
require 'facets/string/snakecase'
require 'english/inflect'

require 'zendesk_api_client_rb/resource'
require 'zendesk_api_client_rb/resources'

module Zendesk
  class Collection
    attr_reader :count
    def initialize(client, resource, path = [], options = {})
      @client, @resource = client, resource
      @options = options
      @path = path

      @verb = @options.delete(:verb)
      @query_path = @options.delete(:path)

      @resource_class = Zendesk.const_get(resource.singular.upper_camelcase)
    end

    def create(attributes = {})
      @resource_class.create(@client, attributes, @path.join("/"))
    end

    def find(id, opts = {})
      @resource_class.find(@client, id, opts)
    end

    def destroy(id)
      @resource_class.destroy(@client, id)
    end

    def per_page(count)
      @options[:per_page] = count
      self
    end

    def page(number)
      @options[:page] = number
      self
    end

    def fetch(reload = false)
      return @resources if @resources && !reload

      response = @client.connection.send(@verb || "get", @query ? @query : "#{@query_path || @resource}.json") do |req|
        req.params = @options
      end

      if response.status == 200
        @resources = response.body[@resource].map do |res|
          @resource_class.new(@client, res, @path.dup)
        end

        @count = (response.body["count"] || @resources.size).to_i
        @next_page, @prev_page = response.body["next_page"], response.body["previous_page"]

        @resources
      else
        []
      end
    end

    def each(&block)
      fetch.each(&block)
    end

    # Depends on what users want
    def next
      if @options[:page]
        @resources = nil
        @options[:page] += 1
      elsif @next_page
        @query = @next_page
        fetch(true).tap { @query = nil }
      else
        []
      end
    end

    def prev
      if @options[:page] > 0
        @resources = nil
        @options[:page] -= 1
      elsif @prev_page
        @query = @prev_page
        fetch(true).tap { @query = nil }
      else
        []
      end
    end

    def method_missing(*args)
      fetch.send(*args)
    end
  end
end

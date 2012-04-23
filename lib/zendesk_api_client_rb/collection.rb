require 'facets/string/camelcase'
require 'facets/string/snakecase'
require 'english/inflect'

require 'zendesk_api_client_rb/resource'
require 'zendesk_api_client_rb/resources'

module Zendesk
  class Collection
    attr_reader :count
    def initialize(client, resource, body, path = [])
      @client, @resource = client, resource
      @path = path

      @resource_class = Zendesk.const_get(resource.singular.upper_camelcase)
      @resources = body[resource].map do |res|
        @resource_class.new(client, res, path.dup)
      end

      super(@resources)

      @next_page, @prev_page = body["next_page"], body["previous_page"]
      @count = (body["count"] || size).to_i
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

    def fetch
    end

    def next
      if @next_page
        Collection.new(@client, @resource, @client.connection.get(@next_page).body)
      else
        []
      end
    end

    def prev
      if @prev_page
        Collection.new(@client, @resource, @client.connection.get(@prev_page).body)
      else
        []
      end
    end
  end
end

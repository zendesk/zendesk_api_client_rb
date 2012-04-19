module Zendesk
  class Collection < Array
    attr_reader :count
    def initialize(client, resource, body)
      @client, @resource = client, resource

      @resources = body[resource.to_s]
      @count = body["count"].to_i
      @next_page, @prev_page = body["next_page"], body["previous_page"]

      super(@resources)
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



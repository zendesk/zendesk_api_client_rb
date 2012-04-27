module Zendesk  
  module Read
    # Finds a resource by an id and any options passed in.
    # A custom path to search at can be passed into opts. It defaults to the {DataResource.resource_name} of the class. 
    # @param [Client] client The {Client} object to be used
    # @param [Number] id The id to GET
    # @param [Hash] opts Any additional GET parameters to be added
    def find(client, id, opts = {})
      path = opts.delete(:path)
      path = resource_name if path.nil? || path.empty?

      response = client.connection.get("#{path}/#{id}.json") do |req|
        req.params = opts
      end

      new(client, response.body)
    rescue Faraday::Error::ClientError => e
      nil
    end
  end

  module Create
    # Create a resource given the attributes passed in.
    # @param [Client] client The {Client} object to be used
    # @param [Hash] attributes The attributes to create.
    # @param [String] path The optional path to use. Defaults to {DataResource.resource_name}. 
    def create(client, attributes = {}, path = "")
      path = resource_name if path.empty?

      response = client.connection.post("#{path}.json") do |req|
        req.body = attributes
      end

      new(client, response.body)
    rescue Faraday::Error::ClientError => e
      nil
    end
  end

  module Destroy
    # Deletes a resource given the id passed in.
    # @param [Client] client The {Client} object to be used
    # @param [Number] id The id to DELETE.
    # @param [String] path The optional path to use. Defaults to {DataResource.resource_name}. 
    def destroy(client, id, path = "")
      path = resource_name if path.empty?

      client.connection.delete("#{path}/#{id}.json")
      true
    rescue Faraday::Error::ClientError => e
      false
    end
  end
end

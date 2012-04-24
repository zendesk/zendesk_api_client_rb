module Zendesk  
  module Read
    def find(client, id, opts = {})
      path = opts.delete(:path)
      path = resource_name if path.nil? || path.empty?

      response = client.connection.get("#{path}/#{id}.json") do |req|
        req.params = opts
      end

      new(client, response.body, [resource_name])
    rescue Faraday::Error::ClientError => e
      nil
    end
  end

  module Create
    def create(client, attributes = {}, path = "")
      path = resource_name if path.empty?

      response = client.connection.post("#{path}.json") do |req|
        req.body = whitelist_attributes(attributes, :post)
      end

      new(client, response.body, [resource_name])
    rescue Faraday::Error::ClientError => e
      nil
    end
  end

  module Destroy
    def destroy(client, id, path = "")
      path = resource_name if path.empty?

      client.connection.delete("#{path}/#{id}.json")
      true
    rescue Faraday::Error::ClientError => e
      false
    end
  end
end

module ZendeskAPI
  module Read
    include ResponseHandler
    include ZendeskAPI::Sideloading

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Reloads a resource.
    def reload!
      response = @client.connection.get(path) do |req|
        yield req if block_given?
      end

      handle_response(response)
      resource.set_includes(resource, includes, response.body) if includes
      attributes.clear_changes

      self
    end

    module ClassMethods
      # Finds a resource by an id and any options passed in.
      # A custom path to search at can be passed into opts. It defaults to the {Data.resource_name} of the class.
      # @param [Client] client The {Client} object to be used
      # @param [Hash] options Any additional GET parameters to be added
      def find!(client, options = {})
        new(client).tap(&:reload!)
      end

      # Finds, returning nil if it fails
      # @param [Client] client The {Client} object to be used
      # @param [Hash] options Any additional GET parameters to be added
      def find(client, options = {}, &block)
        find!(client, options, &block)
      rescue ZendeskAPI::Error::ClientError => e
        nil
      end
    end
  end
end

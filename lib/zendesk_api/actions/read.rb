module ZendeskAPI
  module Read
    include ZendeskAPI::Sideloading

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Reloads a resource.
    def reload!
      # raise unless path

      response = @client.connection.get(path.format(attributes)) do |req|
        req.params.merge!(include: includes.join(',')) if includes.any?

        yield req if block_given?
      end

      # TODO JobStatus -> All of this in handle_response?
      handle_response(response)
      set_includes(self, includes, response.body) if includes.any?
      attributes.clear_changes

      self
    end

    module ClassMethods
      # Finds a resource by an id and any options passed in.
      # A custom path to search at can be passed into opts. It defaults to the {Data.resource_name} of the class.
      # @param [Client] client The {Client} object to be used
      # @param [Hash] options Any additional GET parameters to be added
      def find!(client, options = {})
        new(client, options).tap(&:reload!)
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

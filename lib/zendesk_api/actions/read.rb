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
      attributes.clear_changes
      self
    end

    module ClassMethods
      # Finds a resource by an id and any options passed in.
      # A custom path to search at can be passed into opts. It defaults to the {Data.resource_name} of the class.
      # @param [Client] client The {Client} object to be used
      # @param [Hash] options Any additional GET parameters to be added
      def find!(client, options = {})
        @client = client # so we can use client.logger in rescue

        raise ArgumentError, "No :id given" unless options[:id] || options["id"] || ancestors.include?(SingularResource)
        association = options.delete(:association) || Association.new(:class => self)

        includes = Array(options[:include])
        options[:include] = includes.join(",") if includes.any?

        response = client.connection.get(association.generate_path(options)) do |req|
          req.params = options

          yield req if block_given?
        end

        new_from_response(client, response, includes)
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

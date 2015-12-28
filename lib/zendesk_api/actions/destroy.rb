module ZendeskAPI
  module Destroy
    def self.included(klass)
      klass.extend(ClassMethod)
    end

    # Has this object been deleted?
    def destroyed?
      @destroyed ||= false
    end

    # If this resource hasn't already been deleted, then do so.
    # @return [Boolean] Successful?
    def destroy!
      return false if destroyed? || new_record?

      @client.connection.delete(path.format(attributes)) do |req|
        yield req if block_given?
      end

      @destroyed = true
    end

    # Destroys, returning false on error.
    def destroy(&block)
      destroy!(&block)
    rescue ZendeskAPI::Error::ClientError
      false
    end

    module ClassMethod
      # Deletes a resource given the id passed in.
      # @param [Client] client The {Client} object to be used
      # @param [Hash] opts The optional parameters to pass. Defaults to {}
      def destroy!(client, opts = {}, &block)
        new(client, opts).destroy!(&block)
      end

      # Destroys, returning false on error.
      def destroy(client, attributes = {}, &block)
        destroy!(client, attributes, &block)
      rescue ZendeskAPI::Error::ClientError
        false
      end
    end
  end
end

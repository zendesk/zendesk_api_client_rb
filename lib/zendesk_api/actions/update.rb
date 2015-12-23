require_relative 'save'

module ZendeskAPI
  module Update
    include Save

    def self.included(klass)
      klass.extend(ClassMethod)
    end

    module ClassMethod
      # Updates, returning false on error.
      def update(client, attributes = {}, &block)
        update!(client, attributes, &block)
      rescue ZendeskAPI::Error::ClientError
        false
      end

      # Updates a resource given the id passed in.
      # @param [Client] client The {Client} object to be used
      # @param [Hash] attributes The attributes to update. Default to {}
      def update!(client, attributes = {}, &block)
        new(client, attributes).tap {|r| r.save!(&block)}
      end
    end
  end
end

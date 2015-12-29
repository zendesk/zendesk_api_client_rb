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
        attrs = attributes.dup

        # FML
        new(client, id: attrs.delete(:id), global: attrs.delete(:global)).tap do |resource|
          resource.attributes.merge!(attrs)
          resource.save!(&block)
        end
      end
    end
  end
end

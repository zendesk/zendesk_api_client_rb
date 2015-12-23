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
      # @param [Hash] attributes The attributes to update. Default to {
      def update!(client, attributes = {}, &block)
        resource = new(client, :id => attributes.delete(:id), :global => attributes.delete(:global), :association => attributes.delete(:association))
        resource.attributes.merge!(attributes)
        resource.save!(:force_update => resource.is_a?(SingularResource), &block)
        resource
      end
    end
  end
end

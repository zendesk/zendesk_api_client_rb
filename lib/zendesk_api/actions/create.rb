require_relative 'save'

module ZendeskAPI
  module Create
    include Save

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Create a resource given the attributes passed in.
      # @param [Client] client The {Client} object to be used
      # @param [Hash] attributes The attributes to create.
      def create!(client, attributes = {}, &block)
        new(client, attributes).tap do |resource|
          resource.save!(&block)
        end
      end

      # Creates, returning nil if it fails
      # @param [Client] client The {Client} object to be used
      # @param [Hash] options Any additional GET parameters to be added
      def create(client, attributes = {}, &block)
        create!(client, attributes, &block)
      rescue ZendeskAPI::Error::ClientError
        nil
      end
    end
  end
end

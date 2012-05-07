module Zendesk
  module Read
    extend Rescue

    # Finds a resource by an id and any options passed in.
    # A custom path to search at can be passed into opts. It defaults to the {DataResource.resource_name} of the class. 
    # @param [Client] client The {Client} object to be used
    # @param [Hash] opts Any additional GET parameters to be added
    def find(client, opts = {})
      association = opts.delete(:association) || Association.new(:class => self)

      response = client.connection.get(association.generate_path(opts)) do |req|
        req.params = opts
      end

      new(client, response.body)
    end

    rescue_client_error :find
  end

  module Create
    extend Rescue

    # Create a resource given the attributes passed in.
    # @param [Client] client The {Client} object to be used
    # @param [Hash] attributes The attributes to create.
    def create(client, attributes = {})
      association = attributes.delete(:association) || Association.new(:class => self)

      response = client.connection.post(association.generate_path(attributes.merge(:with_id => false))) do |req|
        req.body = attributes
      end

      new(client, response.body)
    end

    rescue_client_error :create
  end

  module Destroy
    extend Rescue

    # Deletes a resource given the id passed in.
    # @param [Client] client The {Client} object to be used
    # @param [Number] id The id to DELETE.
    # @param [Hash] opts The optional parameters to pass. Defaults to {}
    def destroy(client, opts = {})
      association = opts.delete(:association) || Association.new(:class => self)

      client.connection.delete(association.generate_path(opts)) do |req|
        req.params = opts
      end

      true
    end

    rescue_client_error :destroy, :with => false
  end

  module Update
    extend Rescue

    # Updates  a resource given the id passed in.
    # @param [Client] client The {Client} object to be used
    # @param [Number] id The id to DELETE.
    # @param [String] path The optional path to use. Defaults to {DataResource.resource_name}. 
    def update(client, attributes = {})
      association = attributes.delete(:association) || Association.new(:class => self)

      client.connection.put(association.generate_path(attributes)) do |req|
        req.body = attributes
      end

      true
    end

    rescue_client_error :update, :with => false
  end
end

module Zendesk  
  module Read
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
    rescue Faraday::Error::ClientError => e
      puts e.message
      puts "\t#{e.response[:body].inspect}" if e.response
      nil
    end
  end

  module Create
    # Create a resource given the attributes passed in.
    # @param [Client] client The {Client} object to be used
    # @param [Hash] attributes The attributes to create.
    def create(client, attributes = {})
      association = attributes.delete(:association) || Association.new(:class => self)

      response = client.connection.post(association.generate_path(attributes.merge(:with_id => false))) do |req|
        req.body = attributes
      end

      new(client, response.body)
    rescue Faraday::Error::ClientError => e
      puts e.message
      puts "\t#{e.response[:body].inspect}" if e.response
      nil
    end
  end

  module Destroy
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
    rescue Faraday::Error::ClientError => e
      puts e.message
      puts "\t#{e.response[:body].inspect}" if e.response
      false
    end
  end

  module Update
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
    rescue Faraday::Error::ClientError => e
      puts e.message
      puts "\t#{e.response[:body].inspect}" if e.response
      false
    end
  end
end

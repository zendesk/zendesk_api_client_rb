require 'hashie'
require 'zendesk/actions'
require 'zendesk/association'
require 'zendesk/verbs'

module Zendesk
  # Represents a resource that only holds data.
  class DataResource
    extend Association
    include Zendesk::ParameterWhitelist

    class << self
      # The singular resource name taken from the class name (e.g. Zendesk::Tickets -> ticket)
      def singular_resource_name
        @singular_resource_name ||= to_s.split("::").last.snakecase
      end

      # The resource name taken from the class name (e.g. Zendesk::Tickets -> tickets)
      def resource_name
        @resource_name ||= singular_resource_name.plural
      end
    end

    # @return [Hash] The resource's attributes
    attr_reader :attributes

    # Create a new resource instance.
    # @param [Client] client The client to use
    # @param [Hash] attributes The optional attributes that describe the resource
    # @param [Array] path Optional path array that represents nested association (defaults to [resource_name]).
    def initialize(client, attributes = {}, path = [])
      @client, @attributes, @path = client, Hashie::Mash.new(attributes), path
      @path.push(self.class.resource_name) if @path.empty?
    end

    # Passes the method onto the attributes hash.
    # If the attributes are nested (e.g. { :tickets => { :id => 1 } }), passes the method onto the nested hash.
    def method_missing(*args, &blk)
      if @attributes.key?(self.class.singular_resource_name)
        @attributes[self.class.singular_resource_name].send(*args, &blk)
      else
        @attributes.send(*args, &blk)
      end
    end

    # Returns the resource id of the object or nil
    def id
      key?(:id) ? method_missing(:id) : nil
    end

    # Returns the path joined by /
    def path
      @path.join("/")
    end

    def to_s
      "#{self.class.singular_resource_name}: #{attributes.inspect}"
    end
    alias :inspect :to_s

    def ==(other)
      other.id == id
    end
    alias :eql :==
    alias :hash :id
  end

  # Represents a resource that can only GET
  class ReadResource < DataResource
    extend Read
  end

  # Represents a resource that can only POST
  class CreateResource < DataResource
    extend Create
  end

  # Represents a resource that can CRUD (create, read, update, delete).
  class Resource < DataResource 
    extend Read
    extend Create
    extend Destroy
    extend Verbs

    def initialize(*args)
      super
      @destroyed = false
    end

    # Has this object been deleted?
    def destroyed?
      @destroyed
    end

    # Has this been object been created server-side? Does this by checking for an id.
    def new_record?
      id.nil? 
    end

    # If this resource hasn't been deleted, then create or save it.
    # Executes a POST if it is a {#new_record?}, otherwise a PUT.
    # Merges returned attributes on success.
    # @return [Boolean] Success?
    def save
      return false if destroyed?

      req_path = path
      if new_record?
        method = :post
      else
        method = :put
        req_path += "/#{id}.json"
      end

      response = @client.connection.send(method, req_path) do |req|
        req.body = self.class.whitelist_attributes(attributes, method)
      end

      @attributes.replace(@attributes.deep_merge(response.body))
      true
    rescue Faraday::Error::ClientError => e
      false
    end

    # If this resource hasn't already been deleted, then do so.
    # @return [Boolean] Successful?
    def destroy
      return false if destroyed?

      response = @client.connection.delete("#{path}/#{id}.json")
      @destroyed = true
    rescue Faraday::Error::ClientError => e
      false
    end
  end

  private

  # Allows using has and has_many without having class defined yet
  # Guesses at Resource, if it's anything else and the class is later
  # reopened under a different superclass, an error will be thrown
  def self.get_class(resource)
    return false if resource.nil?
    res = resource.to_s.modulize

    begin
      const_get(res)
    rescue NameError
      const_set(res, Class.new(Resource))
    end
  end
end

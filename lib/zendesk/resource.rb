require 'zendesk/core_ext/trackie'
require 'zendesk/actions'
require 'zendesk/association'
require 'zendesk/verbs'

module Zendesk
  # Represents a resource that only holds data.
  class Data
    extend Associations

    class << self
      # The singular resource name taken from the class name (e.g. Zendesk::Tickets -> ticket)
      def singular_resource_name
        @singular_resource_name ||= to_s.split("::").last.snakecase
      end

      # The resource name taken from the class name (e.g. Zendesk::Tickets -> tickets)
      def resource_name
        @resource_name ||= singular_resource_name.plural
      end

      def singular_resource
        @singular_resource ||= true
      end
    end

    # @return [Hash] The resource's attributes
    attr_reader :attributes
    # @return [Zendesk::Association] The association
    attr_accessor :association

    # Create a new resource instance.
    # @param [Client] client The client to use
    # @param [Hash] attributes The optional attributes that describe the resource
    # @param [Array] path Optional path array that represents nested association (defaults to [resource_name]).
    def initialize(client, attributes = {})
      @client, @attributes = client, Zendesk::Trackie.new(attributes)
      @association = @attributes.delete(:association) || Association.new(:class => self.class)

      unless new_record?
        @attributes.clear_changes
      end
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

    # Returns the path to the resource
    def path(*args)
      @association.generate_path(self, *args)
    end

    def to_s
      "#{self.class.singular_resource_name}: #{attributes.inspect}"
    end
    alias :inspect :to_s

    def ==(other)
      warn "Trying to compare #{other.class} to a Resource" unless other.is_a?(Data)
      other.id == id
    end
    alias :eql :==
    alias :hash :id

    alias :to_param :attributes
  end

  # Indexable resource
  class DataResource < Data
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
    extend Update
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

      if new_record?
        method = :post
        req_path = path(:with_id => false)
      else
        method = :put
        req_path = url || path
      end

      assoc_attrs = attributes[self.class.singular_resource_name] || attributes
      self.class.associations.each do |assoc|
        if assoc[:save]
          assoc_id = "#{assoc[:name]}_id" 
          singular_assoc_ids = "#{assoc[:name].to_s.singular}_ids" 
          assoc_obj = send(assoc[:name])
          next unless assoc_obj
          assoc_obj.save if assoc_obj.respond_to?(:save)

          if has_key?(assoc_id)
            assoc_attrs[assoc_id] = assoc_obj.id
          elsif has_key?(singular_assoc_ids)
            assoc_attrs[singular_assoc_ids] = assoc_obj.map(&:id)
          else
            assoc_attrs[assoc[:name]] = assoc_obj.is_a?(Collection) ? assoc_obj.map(&:to_param) : assoc_obj.to_param
          end
        end
      end

      response = @client.connection.send(method, req_path) do |req|
        req.body = attributes.changes
      end

      @attributes.replace(@attributes.deep_merge(response.body))
      @attributes.clear_changes
      true
    rescue Faraday::Error::ClientError => e
      puts e.message
      puts "\t#{e.response[:body].inspect}" if e.response
      false
    end

    # If this resource hasn't already been deleted, then do so.
    # @return [Boolean] Successful?
    def destroy
      return false if destroyed? || new_record?

      response = @client.connection.delete(url || path)

      @destroyed = true
    rescue Faraday::Error::ClientError => e
      puts e.message
      puts "\t#{e.response[:body].inspect}" if e.response
      false
    end
  end

  class SingularResource < Resource; end
end

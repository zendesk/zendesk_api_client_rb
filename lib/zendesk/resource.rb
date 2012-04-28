require 'zendesk/core_ext/trackie'
require 'zendesk/actions'
require 'zendesk/association'
require 'zendesk/verbs'

module Zendesk
  # Represents a resource that only holds data.
  class DataResource
    extend Association

    class << self
      # The singular resource name taken from the class name (e.g. Zendesk::Tickets -> ticket)
      def singular_resource_name
        @singular_resource_name ||= to_s.split("::").last.snakecase
      end

      # The resource name taken from the class name (e.g. Zendesk::Tickets -> tickets)
      def resource_name
        @resource_name ||= singular_resource_name.plural
      end

      def parent_name
        return @parent_name if @parent_name

        path
        @parent_name
      end

      def path
        return @path if @path

        ary = to_s.split("::")
        ary.delete("Zendesk")
        ary[0] = Zendesk.get_class(ary[0])

        if ary.size > 1
          ary[1] = ary[0].associations[ary[0].get_class(ary[1])][:name].to_s
          ary.insert(1, "%s")
          @parent_name = "#{ary[0].singular_resource_name}_id"
        end

        ary[0] = ary[0].resource_name
        @path = ary.join("/")
      end
    end

    # @return [Hash] The resource's attributes
    attr_reader :attributes

    # Create a new resource instance.
    # @param [Client] client The client to use
    # @param [Hash] attributes The optional attributes that describe the resource
    # @param [Array] path Optional path array that represents nested association (defaults to [resource_name]).
    def initialize(client, attributes = {})
      @client, @attributes = client, Zendesk::Trackie.new(attributes)

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
    def path
      return @path if @path
      @path = self.class.path
      @path %= send(self.class.parent_name) if self.class.parent_name
      @path
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

    alias :to_param :attributes
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

      if new_record?
        method = :post
        req_path = path
      else
        method = :put
        req_path = url || "#{path}/#{id}.json"
      end

      attrs = attributes.changes

      assoc_attrs = attrs[self.class.singular_resource_name] || attrs
      self.class.associations.each do |klass, assoc|
        if assoc[:save]
          assoc_id = "#{assoc[:name]}_id"
          assoc_obj = send(assoc[:name])
          next unless assoc_obj

          if has_key?(assoc_id)
            assoc_attrs[assoc_id] = assoc_obj.id
          elsif has_key?(assoc_id + "s")
            assoc_attrs[assoc_id + "s"] = assoc_obj.map(&:id)
          else
            assoc_obj.save if assoc_obj.respond_to?(:save)
            assoc_attrs[assoc[:name]] = assoc_obj.is_a?(Collection) ? assoc_obj.map(&:to_param) : assoc_obj.to_param
          end
        end
      end

      response = @client.connection.send(method, req_path) do |req|
        req.body = attrs
      end

      @attributes.replace(@attributes.deep_merge(response.body))
      @attributes.clear_changes
      true
    rescue Faraday::Error::ClientError => e
      puts e.message
      false
    end

    # If this resource hasn't already been deleted, then do so.
    # @return [Boolean] Successful?
    def destroy
      return false if destroyed? || new_record?

      response = @client.connection.delete(url || "#{path}/#{id}.json")

      @destroyed = true
    rescue Faraday::Error::ClientError => e
      puts e.message
      false
    end
  end
end

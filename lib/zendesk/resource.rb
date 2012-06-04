require 'zendesk/trackie'
require 'zendesk/actions'
require 'zendesk/association'
require 'zendesk/verbs'

module Zendesk
  # Represents a resource that only holds data.
  class Data
    include Associations
    extend Rescue

    class << self
      # The singular resource name taken from the class name (e.g. Zendesk::Tickets -> ticket)
      def singular_resource_name
        @singular_resource_name ||= to_s.split("::").last.snakecase
      end

      # The resource name taken from the class name (e.g. Zendesk::Tickets -> tickets)
      def resource_name
        @resource_name ||= singular_resource_name.plural
      end

      alias :model_key :resource_name

      # Rails tries to load dependencies, which messes up automatic resource our own loading
      if method_defined?(:const_missing_without_dependencies)
        alias :const_missing :const_missing_without_dependencies
      end
    end

    # @return [Hash] The resource's attributes
    attr_reader :attributes
    # @return [Zendesk::Association] The association
    attr_accessor :association

    # Create a new resource instance.
    # @param [Client] client The client to use
    # @param [Hash] attributes The optional attributes that describe the resource
    def initialize(client, attributes = {})
      @association = (attributes || {}).delete(:association) || Association.new(:class => self.class)
      @client = client
      @attributes = Zendesk::Trackie.new(attributes)
      Zendesk::Client.check_deprecated_namespace_usage @attributes, self.class.singular_resource_name

      @attributes.clear_changes unless new_record?
    end

    # Passes the method onto the attributes hash.
    # If the attributes are nested (e.g. { :tickets => { :id => 1 } }), passes the method onto the nested hash.
    def method_missing(*args, &blk)
      @attributes.send(*args, &blk)
    end

    # Returns the resource id of the object or nil
    def id
      key?(:id) ? method_missing(:id) : nil
    end

    # Has this been object been created server-side? Does this by checking for an id.
    def new_record?
      id.nil? 
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
    extend Verbs
  end

  # Represents a resource that can only GET
  class ReadResource < DataResource
    extend Read
  end

  # Represents a resource that can only POST
  class CreateResource < DataResource
    include Create
  end

  # Represents a resource that can only PUT
  class UpdateResource < DataResource
    include Update
  end

  # Represents a resource that can only DELETE
  class DeleteResource < DataResource
    include Destroy
  end

  # Represents a resource that can CRUD (create, read, update, delete).
  class Resource < DataResource
    def self.only_send_unnested_params
      @unnested_params = true
    end

    def self.unnested_params
      @unnested_params ||= false
    end

    extend Read
    include Create

    include Update 
    include Destroy
  end

  class SingularResource < Resource; end
end

require 'zendesk_api/helpers'
require 'zendesk_api/trackie'
require 'zendesk_api/actions'
require 'zendesk_api/association'
require 'zendesk_api/associations'
require 'zendesk_api/verbs'

module ZendeskAPI
  # Represents a resource that only holds data.
  class Data
    include Associations
    include Rescue

    class << self
      def inherited(klass)
        subclasses.push(klass)
      end

      def subclasses
        @subclasses ||= []
      end

      # The singular resource name taken from the class name (e.g. ZendeskAPI::Ticket -> ticket)
      def singular_resource_name
        @singular_resource_name ||= ZendeskAPI::Helpers.snakecase_string(to_s.split("::").last)
      end

      # The resource name taken from the class name (e.g. ZendeskAPI::Ticket -> tickets)
      def resource_name
        @resource_name ||= Inflection.plural(singular_resource_name)
      end

      alias :model_key :resource_name

      # @private
      def only_send_unnested_params
        @unnested_params = true
      end

      # @private
      def unnested_params
        @unnested_params ||= false
      end
    end

    # @return [Hash] The resource's attributes
    attr_reader :attributes
    # @return [ZendeskAPI::Association] The association
    attr_accessor :association

    # Place to dump the last response
    attr_accessor :response

    # Create a new resource instance.
    # @param [Client] client The client to use
    # @param [Hash] attributes The optional attributes that describe the resource
    def initialize(client, attributes = {})
      raise "Expected a Hash for attributes, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      @association = attributes.delete(:association) || Association.new(:class => self.class)
      @client = client
      @attributes = ZendeskAPI::Trackie.new(attributes)

      if self.class.associations.none? {|a| a[:name] == self.class.singular_resource_name}
        ZendeskAPI::Client.check_deprecated_namespace_usage @attributes, self.class.singular_resource_name
      end

      @attributes.clear_changes unless new_record?
    end

    # Passes the method onto the attributes hash.
    # If the attributes are nested (e.g. { :tickets => { :id => 1 } }), passes the method onto the nested hash.
    def method_missing(*args, &block)
      raise NoMethodError, ":save is not defined" if args.first.to_sym == :save
      @attributes.send(*args, &block)
    end

    # Returns the resource id of the object or nil
    def id
      key?(:id) ? method_missing(:id) : nil
    end

    # Has this been object been created server-side? Does this by checking for an id.
    def new_record?
      id.nil?
    end

    # @private
    def loaded_associations
      self.class.associations.select do |association|
        loaded = @attributes.method_missing(association[:name])
        loaded && !(loaded.respond_to?(:empty?) && loaded.empty?)
      end
    end

    # Returns the path to the resource
    def path(*args)
      @association.generate_path(self, *args)
    end

    # Passes #to_json to the underlying attributes hash
    def to_json(*args)
      method_missing(:to_json, *args)
    end

    # @private
    def to_s
      "#{self.class.singular_resource_name}: #{attributes.inspect}"
    end
    alias :inspect :to_s

    # Compares resources by class and id. If id is nil, then by object_id
    def ==(other)
      warn "Trying to compare #{other.class} to a Resource from #{caller.first}" if other && !other.is_a?(Data)
      other.is_a?(self.class) && ((other.id && other.id == id) || (other.object_id == self.object_id))
    end
    alias :eql :==
    alias :hash :id

    # @private
    def inspect
      "#<#{self.class.name} #{@attributes.to_hash.inspect}>"
    end

    alias :to_param :attributes
  end

  # Indexable resource
  class DataResource < Data
    attr_accessor :error, :error_message
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
    extend Read
    include Create

    include Update
    include Destroy
  end

  class SingularResource < Resource; end
end

require 'zendesk_api/trackie'
require 'zendesk_api/actions'
require 'zendesk_api/association'
require 'zendesk_api/associations'
require 'zendesk_api/verbs'

module ZendeskAPI
  # Represents a resource that only holds data.
  class Data
    include Associations

    class << self
      attr_accessor :resource_name, :singular_resource_name,
        :collection_paths, :resource_paths

      def inherited(klass)
        # TODO just a default
        klass.collection_paths = []
        klass.resource_paths = []

        subclasses.push(klass)
      end

      def subclasses
        @subclasses ||= []
      end

      alias :model_key :resource_name

      def namespace(namespace)
        @namespace = namespace
      end

      def collection_path(options = {})
        if options[:collection_path] && collection_paths.include?(options[:collection_path])
          options[:collection_path]
        else
          collection_paths.lazy.map {|path|
            begin
              path % Hashie.symbolize_keys(options.to_hash)
            rescue KeyError => e
              nil
            end
          }.reject(&:nil?).first
        end
      end

      def path(options = {})
        resource_paths.lazy.map {|path|
          begin
            path % Hashie.symbolize_keys(options.to_hash)
          rescue KeyError => e
            nil
          end
        }.reject(&:nil?).first
      end
    end

    # @return [Hashie::Mash] The resource's attributes
    attr_reader :attributes

    # Place to dump the last response
    attr_accessor :response

    # Create a new resource instance.
    # @param [Client] client The client to use
    # @param [Hash] attributes The optional attributes that describe the resource
    def initialize(client, attributes = {})
      @global_params = attributes.delete(:global) || {}
      @client = client
      @attributes = ZendeskAPI::Trackie.new(attributes)
      @attributes.clear_changes unless new_record?
    end

    # TODO raise NoMethod for actions

    # Passes the method onto the attributes hash.
    def method_missing(*args, &block)
      attributes.send(*args, &block)
    end

    # Has this been object been created server-side? Does this by checking for an id.
    def new_record?
      id.nil?
    end

    # @private
    def loaded_associations
      self.class.associations.select do |association|
        loaded = attributes.method_missing(association[:name])
        loaded && !(loaded.respond_to?(:empty?) && loaded.empty?)
      end
    end

    # Returns the path to the resource
    def path
      self.class.path(attributes)
      # TODO
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
      if other.__id__ == self.__id__
        true
      elsif other.is_a?(Data)
        other.id && other.id == id
      elsif other.is_a?(Integer)
        id == other
      else
        false
      end
    end

    alias :eql? :==

    # @private
    def inspect
      "#<#{self.class.name} #{attributes.to_hash.inspect}>"
    end

    # TODO :id?
    alias :to_param :attributes

    private

    def attributes_for_save
      { self.class.singular_resource_name.to_sym => attributes.changes }
    end
  end

  # Indexable resource
  class DataResource < Data
    attr_accessor :error, :error_message

    extend Verbs
  end

  # Represents a resource that can only GET
  class ReadResource < DataResource
    include Read
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
    include Read
    include Create

    include Update
    include Destroy
  end

  class SingularResource < Resource
    protected

    def save_options
      [:put, path]
    end

    def attributes_for_save
      { self.class.resource_name.to_sym => attributes.changes }
    end
  end

  # Namespace parent class for Data/Resource classes
  module DataNamespace
    class << self
      def included(base)
        base.singleton_class.send(:attr_accessor, :namespace)

        @descendants ||= []
        @descendants << base
      end

      def descendants
        @descendants || []
      end
    end
  end
end

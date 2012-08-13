module ZendeskAPI
  # Represents an association between two resources 
  class Association
    # @return [Hash] Options passed into the association
    attr_reader :options

    # Options to pass in
    # * class - Required
    # * parent - Parent instance
    # * path - Optional path instead of resource name 
    def initialize(options = {})
      @options = Hashie::Mash.new(options)
    end

    # Generate a path to the resource.
    # id and <parent>_id attributes will be deleted from passed in options hash if they are used in the built path.
    # Arguments that can be passed in:
    # An instance, any resource instance
    # Hash Options:
    # * with_parent - Include the parent path (false by default)
    # * with_id - Include the instance id, if possible (true)
    def generate_path(*args)
      options = Hashie::Mash.new(:with_id => true)
      if args.last.is_a?(Hash)
        original_options = args.pop
        options.merge!(original_options)
      end

      instance = args.first

      namespace = @options[:class].to_s.split("::")
      namespace.delete("ZendeskAPI")
      has_parent = namespace.size > 1 || (options[:with_parent] && @options.parent)

      if has_parent
        parent_class = @options.parent ? @options.parent.class : ZendeskAPI.get_class(namespace[0])
        parent_namespace = build_parent_namespace(parent_class, instance, options, original_options)
        namespace[1..1] = parent_namespace if parent_namespace
        namespace[0] = parent_class.resource_name
      else
        namespace[0] = @options.path || @options[:class].resource_name
      end

      if id = extract_id(instance, options, original_options)
        namespace << id
      end

      namespace.join("/")
    end

    private

    def build_parent_namespace(parent_class, instance, options, original_options)
      return unless association_on_parent = parent_class.associations.detect {|a| a[:class] == @options[:class] }
      [
        extract_parent_id(parent_class, instance, options, original_options),
        @options.path || association_on_parent[:name].to_s
      ]
    end

    def extract_parent_id(parent_class, instance, options, original_options)
      parent_id_column = "#{parent_class.singular_resource_name}_id"

      if @options.parent
        @options.parent.id
      elsif instance
        instance.send(parent_id_column)
      elsif options[parent_id_column]
        original_options.delete(parent_id_column) || original_options.delete(parent_id_column.to_sym)
      else
        raise ArgumentError.new("#{@options[:class].resource_name} requires #{parent_id_column} or parent")
      end
    end

    def extract_id(instance, options, original_options)
      if options[:with_id] && !@options[:class].ancestors.include?(SingularResource)
        if instance && instance.id
          instance.id
        elsif options[:id]
          original_options.delete(:id) || original_options.delete("id")
        end
      end
    end
  end

  # This module holds association method for resources.
  # Associations can be loaded in three ways:
  # * Commonly used resources are automatically side-loaded server side and sent along with their parent object.
  # * Associated resource ids are sent and are then loaded one-by-one into the parent collection.
  # * The association is represented with Rails' nested association urls (such as tickets/:id/groups) and are loaded that way.
  module Associations
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    def wrap_resource(resource, klass, class_level_association)
      instance_association = Association.new(class_level_association.merge(:parent => self))
      case resource
      when Hash
        klass.new(@client, resource.merge(:association => instance_association))
      when String, Fixnum
        klass.new(@client, :id => resource, :association => instance_association)
      else
        resource.association = instance_association
        resource
      end
    end

    module ClassMethods
      include Rescue

      def associations
        @assocations ||= []
      end

      # Represents a parent-to-child association between resources. Options to pass in are: class, path.
      # @param [Symbol] resource_name The underlying resource name
      # @param [Hash] opts The options to pass to the method definition.
      def has(resource_name, class_level_options = {})
        klass = get_class(class_level_options.delete(:class)) || get_class(resource_name)
        class_level_association = {
          :class => klass,
          :name => resource_name,
          :inline => class_level_options.delete(:inline),
          :path => class_level_options.delete(:path)
        }
        associations << class_level_association
        id_column = "#{resource_name}_id"

        define_method "#{resource_name}_used?" do
          !!instance_variable_get("@#{resource_name}")
        end

        define_method resource_name do |*args|
          instance_options = args.last.is_a?(Hash) ? args.pop : {}

          # return if cached
          cached = instance_variable_get("@#{resource_name}")
          return cached if cached && !instance_options[:reload]

          # find and cache association
          instance_association = Association.new(class_level_association.merge(:parent => self))
          resource = if klass.respond_to?(:find) && resource_id = method_missing(id_column)
            klass.find(@client, :id => resource_id, :association => instance_association)
          elsif found = method_missing(resource_name.to_sym)
            wrap_resource(found, klass, class_level_association)
          elsif klass.ancestors.include?(DataResource)
            rescue_client_error do
              response = @client.connection.get(instance_association.generate_path(:with_parent => true))
              klass.new(@client, response.body[klass.singular_resource_name].merge(:association => instance_association))
            end
          end

          send("#{id_column}=", resource.id) if resource && has_key?(id_column)
          instance_variable_set("@#{resource_name}", resource)
        end

        define_method "#{resource_name}=" do |resource|
          resource = wrap_resource(resource, klass, class_level_association)
          send("#{id_column}=", resource.id) if has_key?(id_column)
          instance_variable_set("@#{resource_name}", resource)
        end
      end

      # Represents a parent-to-children association between resources. Options to pass in are: class, path.
      # @param [Symbol] resource The underlying resource name
      # @param [Hash] opts The options to pass to the method definition.
      def has_many(resource_name, class_level_opts = {})
        klass = get_class(class_level_opts.delete(:class)) || get_class(resource_name.to_s.singular)
        class_level_association = {
          :class => klass,
          :name => resource_name,
          :inline => class_level_opts.delete(:inline),
          :path => class_level_opts.delete(:path)
        }
        associations << class_level_association

        id_column = "#{resource_name}_ids"

        define_method "#{resource_name}_used?" do
          !!instance_variable_get("@#{resource_name}")
        end

        define_method resource_name do |*args|
          instance_opts = args.last.is_a?(Hash) ? args.pop : {}

          # return if cached
          cached = instance_variable_get("@#{resource_name}")
          return cached if cached && !instance_opts[:reload]

          # find and cache association
          instance_association = Association.new(class_level_association.merge(:parent => self))
          singular_resource_name = resource_name.to_s.singular

          resources = if (ids = method_missing("#{singular_resource_name}_ids")) && ids.any?
            ids.map do |id|
              klass.find(@client, :id => id, :association => instance_association)
            end.compact
          elsif (resources = method_missing(resource_name.to_sym)) && resources.any?
            resources.map do |res|
              klass.new(@client, res.merge(:association => instance_association))
            end
          else
            ZendeskAPI::Collection.new(@client, klass, instance_opts.merge(:association => instance_association))
          end

          send("#{id_column}=", resources.map(&:id)) if resource && has_key?(id_column)
          instance_variable_set("@#{resource_name}", resources)
        end

        define_method "#{resource_name}=" do |resources|
          if resources.is_a?(Array)
            resources.map! { |attr| wrap_resource(attr, klass, class_level_association) }
            send(resource_name).replace(resources)
          else
            resources.association = instance_association
            instance_variable_set("@#{resource_name}", resources)
          end

          send("#{id_column}=", resources.map(&:id)) if resources && has_key?(id_column)
          resource
        end
      end

      # Allows using has and has_many without having class defined yet
      # Guesses at Resource, if it's anything else and the class is later
      # reopened under a different superclass, an error will be thrown
      def get_class(resource)
        return false if resource.nil?
        res = resource.to_s.modulize

        begin
          const_get(res)
        rescue NameError
          ZendeskAPI.get_class(resource)
        end
      end
    end
  end

  class << self
    # Make sure Rails' overwriting of const_missing doesn't cause trouble
    def const_missing(*args)
      Object.const_missing(*args)
    end

    # Allows using has and has_many without having class defined yet
    # Guesses at Resource, if it's anything else and the class is later
    # reopened under a different superclass, an error will be thrown
    def get_class(resource)
      return false if resource.nil?
      res = resource.to_s.modulize.split("::")

      begin
        res[1..-1].inject(ZendeskAPI.const_get(res[0])) do |iter, k|
          begin
            iter.const_get(k)
          rescue
            iter.const_set(k, Class.new(Resource))
          end
        end
      rescue NameError
        ZendeskAPI.const_set(res[0], Class.new(Resource))
      end
    end
  end
end

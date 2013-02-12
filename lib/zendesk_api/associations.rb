require 'zendesk_api/helpers'

module ZendeskAPI
  # This module holds association method for resources.
  # Associations can be loaded in three ways:
  # * Commonly used resources are automatically side-loaded server side and sent along with their parent object.
  # * Associated resource ids are sent and are then loaded one-by-one into the parent collection.
  # * The association is represented with Rails' nested association urls (such as tickets/:id/groups) and are loaded that way.
  #
  # @private
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

    # @private
    module ClassMethods
      include Rescue

      def associations
        @associations ||= []
      end

      def associated_with(name)
        associations.inject([]) do |associated_with, association|
          if association[:include] == name.to_s
            associated_with.push(Association.new(association))
          end

          associated_with
        end
      end

      # Represents a parent-to-child association between resources. Options to pass in are: class, path.
      # @param [Symbol] resource_name_or_class The underlying resource name or a class to get it from
      # @param [Hash] class_level_options The options to pass to the method definition.
      def has(resource_name_or_class, class_level_options = {})
        if klass = class_level_options.delete(:class)
          resource_name = resource_name_or_class
        else
          klass = resource_name_or_class
          resource_name = klass.singular_resource_name
        end

        class_level_association = {
          :class => klass,
          :name => resource_name,
          :inline => class_level_options.delete(:inline),
          :path => class_level_options.delete(:path),
          :include => (class_level_options.delete(:include) || klass.resource_name).to_s,
          :include_key => (class_level_options.delete(:include_key) || :id).to_s,
          :singular => true
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
          elsif klass.superclass == DataResource
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
      # @param [Symbol] resource_name_or_class The underlying resource name or class to get it from
      # @param [Hash] class_level_options The options to pass to the method definition.
      def has_many(resource_name_or_class, class_level_options = {})
        if klass = class_level_options.delete(:class)
          resource_name = resource_name_or_class
        else
          klass = resource_name_or_class
          resource_name = klass.resource_name
        end

        class_level_association = {
          :class => klass,
          :name => resource_name,
          :inline => class_level_options.delete(:inline),
          :path => class_level_options.delete(:path),
          :include => (class_level_options.delete(:include) || klass.resource_name).to_s,
          :include_key => (class_level_options.delete(:include_key) || :id).to_s,
          :singular => false
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
          singular_resource_name = Inflection.singular(resource_name.to_s)

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
    end
  end
end

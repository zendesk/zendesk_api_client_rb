require 'zendesk_api/association'
require 'zendesk_api/associations/has'
require 'zendesk_api/associations/has_many'

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
      base.extend(ClassMethods)
    end

    def associations
      @associations ||= {}
    end

    def wrap_plural_resource(resources, options = {})
      mapped_resources = Array(resources).map do |resource|
        wrap_singular_resource(resource, options)
      end

      # TODO pass in proper path ?
      path = options[:path].format(attributes)

      ZendeskAPI::Collection.new(client, options[:class], path: path).tap do |collection|
        collection.replace(mapped_resources)

        if resources && has_key?(options[:plural_key])
          public_send("#{options[:plural_key]}=", resources.map(&:id))
        end

        if options[:extensions].any?
          collection.extend(*options[:extensions])
        end
      end
    end

    def wrap_singular_resource(resource, options = {})
      wrapped_resource = case resource
      when Hash
        options[:class].new(@client, resource)
      when String, Fixnum
        options[:class].new(@client, options[:include_key] => resource)
      else
        resource
      end

      if wrapped_resource && has_key?(options[:singular_key])
        send("#{options[:singular_key]}=", wrapped_resource.id)
      end

      wrapped_resource
    end

    # @private
    module ClassMethods
      def self.extended(klass)
        klass.extend(ZendeskAPI::Associations::Has)
        klass.extend(ZendeskAPI::Associations::HasMany)
      end

      def associations
        @associations ||= []
      end

      def associated_with(name)
        associations.lazy.select {|association|
          association[:include] == name.to_s
        }.map {|association|
          Association.new(association)
        }.to_a
      end

      private

      def build_association(resource_name, options)
        {
          name: resource_name,
          class: options.fetch(:class),
          singular_key: "#{resource_name}_id", # This is the association's "resource name"
          plural_key: "#{options.fetch(:class).singular_resource_name}_ids", # TODO
          parent_key: "#{singular_resource_name}_id", # This is RESOURCE CLASSES singular_resource_name
          include_key: options.fetch(:include_key, :id),

          inline: options.fetch(:inline, false), # this is used for saving

          include: options.fetch(:include, options.fetch(:class).resource_name), # ??
          # TODO ?
          extensions: Array(options.delete(:extend))
        }
      end

      def define_used(options)
        define_method "#{options[:name]}_used?" do
          associations.key?(options[:name])
        end
      end
    end
  end
end

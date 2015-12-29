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
        if mapped_resources.any?
          collection.replace(mapped_resources)
        end

        if has_key?(options[:plural_key])
          public_send("#{options[:plural_key]}=", mapped_resources.map(&:id))
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
        public_send("#{options[:singular_key]}=", wrapped_resource.id)
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
          association[:sideload] && association[:sideload][:include].to_s == name.to_s
        }.map {|association|
          Association.new(association)
        }.to_a
      end

      private

      def build_association(resource_name, options)
        {
          name: resource_name,
          class: options.fetch(:class),

          # should this be saved in the parent record?
          inline: options.fetch(:inline, false),

          # sideload options for .includes
          sideload: options.fetch(:sideload, false),

          # really only used for Role
          include_key: options.fetch(:include_key, :id),

          # collection objects can be extended
          extensions: Array(options.delete(:extend)),

          singular_key: options.fetch(:singular_key, "#{resource_name}_id"),
          #plural_key: "#{resource_name}_ids",
          # TODO fuck this
          plural_key: options.fetch(:plural_key, "#{options.fetch(:class).singular_resource_name}_ids")
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

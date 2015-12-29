require 'zendesk_api/association'
require 'zendesk_api/associations/has'
require 'zendesk_api/associations/has_many'
require 'zendesk_api/resource_class_delegator'

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

      base.class_eval do
        include ZendeskAPI::Associations::Has
        include ZendeskAPI::Associations::HasMany
      end
    end

    def associations
      @associations ||= {}
    end

    def wrap_plural_resource(resources, options = {})
      wrapped_resources = Array(resources).map do |resource|
        wrap_singular_resource(resource, options)
      end

      # TODO pass in proper path ?
      path = options[:path].format(attributes)

      ZendeskAPI::Collection.new(client, options[:class].__getobj__, path: path).tap do |collection|
        if wrapped_resources.any?
          collection.replace(wrapped_resources)
        end

        if options[:extensions].any?
          # TODO error handling
          collection.extend(*options[:extensions].map {|ex| ZendeskAPI.const_get(ex)})
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

      wrapped_resource
    end

    # @private
    module ClassMethods
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

      def build_association(resource_name, options, extras)
        {
          name: resource_name,
          class: ResourceClassDelegator.new(options.fetch(:class)),

          # should this be saved in the parent record?
          inline: options.fetch(:inline, false),

          # sideload options for .includes
          sideload: options.fetch(:sideload, false),

          # really only used for Role
          include_key: options.fetch(:include_key, :id),

          # collection objects can be extended
          extensions: Array(options.delete(:extend)),
        }.merge(extras).tap do |association|
          if path = options[:path]
            association[:path] = Path.new(path)
          end

          associations << association
        end
      end

      def define_used(options)
        define_method "#{options[:name]}_used?" do
          associations.key?(options[:name])
        end
      end
    end
  end
end

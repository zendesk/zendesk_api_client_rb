module ZendeskAPI
  module Associations
    module HasMany
      # Represents a parent-to-children association between resources. Options to pass in are: class, path.
      # @param [Symbol] resource_name_or_class The underlying resource name or class to get it from
      # @param [Hash] class_level_options The options to pass to the method definition.
      def has_many(resource_name, class_level_options = {})
        # TODO backwards compatible, but not by default?
        #if !(klass = class_level_options.delete(:class))
        #  resource_name = resource_name_or_class.resource_name...
        #  something something
        #end

        class_level_association = build_association(resource_name, class_level_options)
        class_level_association.merge!(path: Path.new(class_level_options.fetch(:path)))

        associations << class_level_association

        define_used(class_level_association)
        define_has_many_getter(class_level_association)
        define_has_many_setter(class_level_association)
      end

      private

      def define_has_many_getter(options)
        define_method options[:name] do |*|
          associations[options[:name]] ||= begin
            resources = if (ids = public_send(options[:plural_key])) && ids.any?
              ids.map {|id| options[:class].find(@client, id: id)}.compact
            elsif (inline_resources = attributes[options[:name]]) && inline_resources.any?
              inline_resources
            else
              []
            end

            wrap_plural_resource(resources, options)
          end
        end
      end

      def define_has_many_setter(options)
        define_method "#{options[:name]}=" do |resources|
          associations[options[:name]] = wrap_plural_resource(resources, options)
        end
      end
    end
  end
end

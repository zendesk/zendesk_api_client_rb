module ZendeskAPI
  module Associations
    module HasMany
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      def wrap_has_many_resource(resources, options)
        wrap_plural_resource(resources, options).tap do |wrapped_resources|
          if has_key?(options[:key])
            public_send("#{options[:key]}=", wrapped_resources.map(&:id))
          end
        end
      end

      module ClassMethods
        # Represents a parent-to-children association between resources. Options to pass in are: class, path.
        # @param [Symbol] resource_name_or_class The underlying resource name or class to get it from
        # @param [Hash] class_level_options The options to pass to the method definition.
        def has_many(resource_name, options = {})
          class_level_association = build_association(
            resource_name, options,
            #key: "#{resource_name}_ids",
            # TODO fuck this
            key: options.fetch(:key, "#{options.fetch(:class).singular_resource_name}_ids")
          )

          define_used(class_level_association)
          define_has_many_getter(class_level_association)
          define_has_many_setter(class_level_association)
        end

        private

        def define_has_many_getter(options)
          define_method options[:name] do |*|
            associations[options[:name]] ||= begin
              resources = if (ids = public_send(options[:key])) && ids.any?
                ids.map {|id| options[:class].find(@client, id: id)}.compact
              elsif (inline_resources = attributes[options[:name]]) && inline_resources.any?
                inline_resources
              else
                []
              end

              wrap_has_many_resource(resources, options)
            end
          end
        end

        def define_has_many_setter(options)
          define_method "#{options[:name]}=" do |resources|
            associations[options[:name]] = wrap_has_many_resource(resources, options)
          end
        end
      end
    end
  end
end

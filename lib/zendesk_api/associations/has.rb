module ZendeskAPI
  module Associations
    module Has
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      def wrap_has_resource(resource, options)
        wrap_singular_resource(resource, options).tap do |wrapped_resource|
          if has_key?(options[:key])
            public_send("#{options[:key]}=", wrapped_resource && wrapped_resource.id)
          end
        end
      end

      module ClassMethods
        # Represents a parent-to-child association between resources. Options to pass in are: class, path.
        # @param [Symbol] resource_name_or_class The underlying resource name or a class to get it from
        # @param [Hash] class_level_options The options to pass to the method definition.
        def has(resource_name, options = {})
          class_level_association = build_association(
            resource_name, options,
            key: options.fetch(:key, "#{resource_name}_id")
          )

          define_used(class_level_association)
          define_has_getter(class_level_association)
          define_has_setter(class_level_association)
        end

        private

        def define_has_getter(options)
          define_method options[:name] do |*|
            associations[options[:name]] ||= begin
              resource = if options[:class].respond_to?(:find) && (resource_id = attributes[options[:key]])
                options[:class].find(@client, id: resource_id)
              elsif loaded_resource = attributes[options[:name]]
                loaded_resource
              elsif options[:class].superclass == DataResource && !options[:inline] && options[:path].matches?(attributes)
                loaded_resource = options[:class].new(@client)

                response = @client.connection.get(options[:path].format(attributes))

                # TODO what about wrap_singular_resource?
                loaded_resource.handle_response(response)
                loaded_resource
              end

              wrap_has_resource(resource, options)
            end
          end

          # define_method("reload_#{options[:name]}")
        end

        def define_has_setter(options)
          define_method "#{options[:name]}=" do |resource|
            associations[options[:name]] = wrap_has_resource(resource, options)
          end
        end
      end
    end
  end
end

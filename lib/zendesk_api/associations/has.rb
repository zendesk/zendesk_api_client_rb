module ZendeskAPI
  module Associations
    module Has
      # Represents a parent-to-child association between resources. Options to pass in are: class, path.
      # @param [Symbol] resource_name_or_class The underlying resource name or a class to get it from
      # @param [Hash] class_level_options The options to pass to the method definition.
      def has(resource_name, class_level_options = {})
        # TODO maybe...
        # if klass = class_level_options.delete(:class)

        class_level_association = build_association(resource_name, class_level_options)

        if path = class_level_options[:path]
          class_level_association.merge!(path: Path.new(path))
        end

        associations << class_level_association

        define_used(class_level_association)
        define_has_getter(class_level_association)
        define_has_setter(class_level_association)
      end

      private

      def define_has_getter(options)
        define_method options[:name] do |*|
          associations[options[:name]] ||= begin
            resource = if options[:class].respond_to?(:find) && (resource_id = attributes[options[:singular_key]])
              options[:class].find(@client, id: resource_id)
            elsif loaded_resource = attributes[options[:name]]
              loaded_resource
            elsif options[:class].superclass == DataResource && !options[:inline] && options[:path].matches?(attributes)
              response = @client.connection.get(options[:path].format(attributes))
              loaded_resource = options[:class].new(@client)
              # TODO what about wrap_singular_resource?
              loaded_resource.handle_response(response)
              loaded_resource
            end

            wrap_singular_resource(resource, options)
          end
        end

        # define_method("reload_#{options[:name]}")
      end

      def define_has_setter(options)
        define_method "#{options[:name]}=" do |resource|
          associations[options[:name]] = wrap_singular_resource(resource, options)
        end
      end
    end
  end
end

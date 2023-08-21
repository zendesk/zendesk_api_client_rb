module ZendeskAPI
  class SideLoad
    class << self
      attr_reader :options

      def side_load(resources, side_loads)
        key = "#{options.name}_id"
        plural_key = "#{Inflection.singular options.name.to_s}_ids"

        resources.each do |resource|
          if resource.key?(plural_key) # Grab associations from child_ids field on resource
            side_load_from_child_ids(resource, side_loads, plural_key)
          elsif resource.key?(key) || options.singular
            side_load_from_child_or_parent_id(resource, side_loads, key)
          else # Grab associations from parent_id field from multiple child resources
            side_load_from_parent_id(resource, side_loads, key)
          end
        end
      end

      private

      def _side_load(resource, side_loads)
        side_loads.map! do |side_load|
          resource.send(:wrap_resource, side_load, options)
        end

        ZendeskAPI::Collection.new(resource.client, options[:class]).tap do |collection|
          collection.replace(side_loads)
        end
      end

      def side_load_from_parent_id(resource, side_loads, key)
        key = "#{resource.class.singular_resource_name}_id"

        resource.send("#{options.name}=", _side_load(resource, side_loads.select { |side_load|
          side_load[key] == resource.id
        }))
      end

      def side_load_from_child_ids(resource, side_loads, plural_key)
        ids = resource.send(plural_key)

        resource.send("#{options.name}=", _side_load(resource, side_loads.select { |side_load|
          ids.include?(side_load[options.include_key])
        }))
      end

      def side_load_from_child_or_parent_id(resource, side_loads, key)
        # Either grab association from child_id field on resource or parent_id on child resource
        if resource.key?(key)
          id = resource.send(key)
          include_key = options.include_key
        else
          id = resource.id
          include_key = "#{resource.class.singular_resource_name}_id"
        end

        return unless id

        side_load = side_loads.detect do |side_load|
          id == side_load[include_key]
        end

        resource.send("#{options.name}=", side_load) if side_load
      end
    end
  end
end

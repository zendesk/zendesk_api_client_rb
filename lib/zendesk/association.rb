module Zendesk
  # This model holds association method for resources.
  # Associations can be loaded in three ways:
  # * Commonly used resources are automatically side-loaded server side and sent along with their parent object.
  # * Associated resource ids are sent and are then loaded one-by-one into the parent collection.
  # * The association is represented with Rails' nested association urls (such as tickets/:id/groups) and are loaded that way.
  module Association
    def associations
      @assocations ||= {}
    end

    def has_parent(resource, opts = {})
      has(resource, opts)

      define_method :parent do
        return instance_variable_get(:@parent) if instance_variable_defined?(:@parent)
        instance_variable_set(:@parent, send(resource))
      end
    end

    # Represents a parent-to-child association between resources. Options to pass in are: class, path.
    # @param [Symbol] resource The underlying resource name
    # @param [Hash] opts The options to pass to the method definition. 
    def has(resource, opts = {})
      klass = Zendesk.get_class(opts.delete(:class)) || Zendesk.get_class(resource)
      singular = resource.to_s.singular
      associations[klass] = { :name => !!opts.delete(:singular) ? singular : resource, :only => !!opts.delete(:only) }

      define_method resource do |*args|
        options = args.last.is_a?(Hash) ? args.pop : {}
        return instance_variable_get("@#{resource}") if instance_variable_defined?("@#{resource}") && !options[:reload]

        if res_id = method_missing("#{resource}_id")
          obj = klass.find(@client, res_id)
          obj.tap { instance_variable_set("@#{resource}", obj) if obj }
        elsif (res = method_missing(resource.to_sym)) && res.is_a?(Hash)
          instance_variable_set("@#{resource}", klass.new(@client, res))
        else
          begin
            response = @client.connection.get("#{path}/#{id}/#{opts[:path] || resource}.json")
            instance_variable_set("@#{resource}", klass.new(@client, response.body))
          rescue Faraday::Error::ClientError => e
            nil
          end
        end
      end
    end

    # Represents a parent-to-children association between resources. Options to pass in are: class, path, set_path.
    # @param [Symbol] resource The underlying resource name
    # @param [Hash] opts The options to pass to the method definition. 
    def has_many(resource, opts = {})
      klass = Zendesk.get_class(opts.delete(:class)) || Zendesk.get_class(resource.to_s.singular)
      singular = resource.to_s.singular
      associations[klass] = { :name => !!opts.delete(:singular) ? singular : resource, :only => !!opts.delete(:only) }

      define_method resource do |*args|
        options = args.last.is_a?(Hash) ? args.pop : {}
        return instance_variable_get("@#{resource}") if instance_variable_defined?("@#{resource}") && !options[:reload]

        singular = resource.to_s.singular

        if (ids = method_missing("#{singular}_ids")) && ids.any?
          collection = ids.map do |id| 
            klass.find(@client, id)
          end.compact

          instance_variable_set("@#{resource}", collection)
        elsif (resources = method_missing(resource.to_sym)) && resources.any?
          loaded_resources = resources.map do |res|
            klass.new(@client, { klass.resource_name => res })
          end

          instance_variable_set("@#{resource}", loaded_resources)
        else
          new_path = @path.dup.push(id)
          options[:path] = new_path.dup.push(opts[:path]).join("/") if opts[:path]
          new_path.push(resource.to_s)

          instance_variable_set("@#{resource}", Zendesk::Collection.new(@client, klass.resource_name, new_path, options))
        end
      end
    end
  end
end

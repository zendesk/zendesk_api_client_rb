module Zendesk
  module Association
    def has(resource, opts = {})
      klass = Zendesk.get_class(opts.delete(:class)) || Zendesk.get_class(resource)

      define_method resource do |*args|
        options = args.last.is_a?(Hash) ? args.pop : {}
        return instance_variable_get("@#{resource}") if instance_variable_defined?("@#{resource}") && !options[:reload]

        if res_id = @attributes["#{resource}_id"]
          obj = klass.find(@client, res_id)
          obj.tap { instance_variable_set("@#{resource}", obj) if obj }
        elsif (res = @attributes[resource.to_s]) && res.is_a?(Hash)
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

    def has_many(resource, opts = {})
      klass = Zendesk.get_class(opts.delete(:class)) || Zendesk.get_class(resource.to_s.singular)

      define_method resource do |*args|
        options = args.last.is_a?(Hash) ? args.pop : {}
        return instance_variable_get("@#{resource}") if instance_variable_defined?("@#{resource}") && !options[:reload]

        singular = resource.to_s.singular

        if (ids = @attributes["#{singular}_ids"]) && ids.any?
          collection = ids.map do |id| 
            klass.find(@client, id)
          end.compact

          instance_variable_set("@#{resource}", collection)
        elsif (resources = @attributes[resource.to_s]) && resources.any?
          loaded_resources = resources.map do |res|
            klass.new(@client, { klass.resource_name => res })
          end

          instance_variable_set("@#{resource}", loaded_resources)
        else
          if opts[:set_path] || opts[:path]
            new_path = @path.dup.push(id).push(opts[:path] || resource.to_s) 
          else
            new_path = [resource.to_s]
          end

          instance_variable_set("@#{resource}", Zendesk::Collection.new(@client, klass.resource_name, new_path))
        end
      end
    end
  end
end

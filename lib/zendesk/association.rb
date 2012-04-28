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

    # Represents a parent-to-child association between resources. Options to pass in are: class, path.
    # @param [Symbol] resource The underlying resource name
    # @param [Hash] opts The options to pass to the method definition. 
    def has(resource, opts = {})
      klass = get_class(opts.delete(:class)) || get_class(resource)
      associations[klass] = { :name => resource, :save => !!opts.delete(:save) }

      define_method resource do |*args|
        options = args.last.is_a?(Hash) ? args.pop : {}
        return instance_variable_get("@#{resource}") if instance_variable_defined?("@#{resource}") && !options[:reload]

        if res_id = method_missing("#{resource}_id")
          obj = klass.find(@client, res_id)
          obj.tap { instance_variable_set("@#{resource}", obj) if obj }
        elsif (res = method_missing(resource.to_sym)) 
          instance_variable_set("@#{resource}", res.is_a?(Hash) ? klass.new(@client, res) : res)
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

    # Represents a parent-to-children association between resources. Options to pass in are: class, path.
    # @param [Symbol] resource The underlying resource name
    # @param [Hash] opts The options to pass to the method definition. 
    def has_many(resource, opts = {})
      klass = get_class(opts.delete(:class)) || get_class(resource.to_s.singular)
      associations[klass] = { :name => resource, :save => !!opts.delete(:save) }

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
          collection = Zendesk::Collection.new(@client, klass, opts)
          collection.parent = self

          instance_variable_set("@#{resource}", collection)
        end
      end
    end

    # Allows using has and has_many without having class defined yet
    # Guesses at Resource, if it's anything else and the class is later
    # reopened under a different superclass, an error will be thrown
    def get_class(resource)
      return false if resource.nil?
      res = resource.to_s.modulize

      begin
        const_get(res)
      rescue NameError
        Zendesk.get_class(resource)
      end
    end
  end

  # Allows using has and has_many without having class defined yet
  # Guesses at Resource, if it's anything else and the class is later
  # reopened under a different superclass, an error will be thrown
  def self.get_class(resource)
    return false if resource.nil?
    res = resource.to_s.modulize.split("::")

    begin
      res[1..-1].inject(Zendesk.const_get(res[0])) do |iter, k| 
        begin
          iter.const_get(k)
        rescue
          iter.const_set(k, Class.new(Resource))
        end
      end
    rescue NameError
      Zendesk.const_set(res[0], Class.new(Resource))
    end
  end
end

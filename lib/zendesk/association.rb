module Zendesk
  # Represents an association between two resources 
  class Association
    # @return [Hash] Options passed into the association
    attr_reader :options

    # Options to pass in
    # * class - Required
    # * parent - Parent instance
    # * path - Optional path instead of resource name 
    def initialize(options = {})
      @options = Hashie::Mash.new(options)
    end

    # Generate a path to the resource
    # Arguments that can be passed in:
    # An instance, any resource instance
    # Hash Options:
    # * with_parent - Include the parent path (false by default)
    # * with_id - Include the instance id, if possible (true)
    def generate_path(*args)
      options = Hashie::Mash.new(:with_id => true)
      if args.last.is_a?(Hash)
        hash_argument = args.pop 
        options.merge!(hash_argument)
      end

      instance = args.first

      ary = @options[:class].to_s.split("::")
      ary.delete("Zendesk")

      if ary.size > 1 || (options[:with_parent] && @options.parent)
        parent_class = @options.parent ? @options.parent.class : Zendesk.get_class(ary[0])
        association = parent_class.associations.detect {|a| a[:class] == @options[:class]}

        if association
          ary[1] = @options.path || association[:name].to_s
          parent_name = "#{parent_class.singular_resource_name}_id"
          
          if @options.parent
            ary.insert(1, @options.parent.id)
          elsif instance
            ary.insert(1, instance.send(parent_name))
          elsif options[parent_name]
            ary.insert(1, hash_argument.delete(parent_name) || hash_argument.delete(parent_name.to_sym))
          else
            raise ArgumentError.new("#{@options[:class].resource_name} require parent id")
          end
        end

        ary[0] = parent_class.resource_name
      else
        ary[0] = @options.path || @options[:class].resource_name
      end

      options[:with_id] &&= !@options[:class].ancestors.include?(SingularResource)
      if options[:with_id]
        if instance && instance.id
          ary << instance.id
        elsif options[:id]
          ary << (hash_argument.delete(:id) || hash_argument.delete("id"))
        end
      end

      ary.join("/")
    end
  end

  # This module holds association method for resources.
  # Associations can be loaded in three ways:
  # * Commonly used resources are automatically side-loaded server side and sent along with their parent object.
  # * Associated resource ids are sent and are then loaded one-by-one into the parent collection.
  # * The association is represented with Rails' nested association urls (such as tickets/:id/groups) and are loaded that way.
  module Associations
    def associations
      @assocations ||= []
    end

    # Represents a parent-to-child association between resources. Options to pass in are: class, path.
    # @param [Symbol] resource The underlying resource name
    # @param [Hash] opts The options to pass to the method definition. 
    def has(resource, class_level_opts = {})
      klass = get_class(class_level_opts.delete(:class)) || get_class(resource)
      class_level_association = { :class => klass, :name => resource, :save => !!class_level_opts.delete(:save), :path => class_level_opts.delete(:path) }
      associations << class_level_association

      define_method resource do |*args|
        instance_opts = args.last.is_a?(Hash) ? args.pop : {}
        return instance_variable_get("@#{resource}") if instance_variable_defined?("@#{resource}") && !instance_opts[:reload]

        instance_association = Association.new(class_level_association.merge(:parent => self))

        if res_id = method_missing("#{resource}_id")
          obj = klass.find(@client, :id => res_id, :association => instance_association)
          obj.tap { instance_variable_set("@#{resource}", obj) if obj }
        elsif (res = method_missing(resource.to_sym)) 
          if res.is_a?(Hash)
            res = klass.new(@client, res.merge(:association => instance_association))
          else
            res.association = instance_association
          end

          instance_variable_set("@#{resource}", res)
        elsif klass.ancestors.include?(DataResource)
          begin
            response = @client.connection.get(instance_association.generate_path(:with_parent => true))
            res = klass.new(@client, response.body.merge(:association => instance_association)) 
            instance_variable_set("@#{resource}", res)
          rescue Faraday::Error::ClientError => e
            nil
          end
        end
      end

      define_method "#{resource}=" do |res|
        instance_association = Association.new(class_level_association.merge(:parent => self))

        if res.is_a?(Hash)
          res = klass.new(@client, res.merge(:association => instance_association))
        else
          res.association = instance_association
        end

        instance_variable_set("@#{resource}", res)
      end
    end

    # Represents a parent-to-children association between resources. Options to pass in are: class, path.
    # @param [Symbol] resource The underlying resource name
    # @param [Hash] opts The options to pass to the method definition. 
    def has_many(resource, class_level_opts = {})
      klass = get_class(class_level_opts.delete(:class)) || get_class(resource.to_s.singular)
      class_level_association = { :class => klass, :name => resource, :save => !!class_level_opts.delete(:save), :path => class_level_opts.delete(:path) }
      associations << class_level_association

      define_method resource do |*args|
        instance_opts = args.last.is_a?(Hash) ? args.pop : {}
        return instance_variable_get("@#{resource}") if instance_variable_defined?("@#{resource}") && !instance_opts[:reload]

        instance_association = Association.new(class_level_association.merge(:parent => self))
        singular_resource_name = resource.to_s.singular

        if (ids = method_missing("#{singular_resource_name}_ids")) && ids.any?
          collection = ids.map do |id| 
            klass.find(@client, :id => id, :association => instance_association)
          end.compact

          instance_variable_set("@#{resource}", collection)
        elsif (resources = method_missing(resource.to_sym)) && resources.any?
          loaded_resources = resources.map do |res|
            klass.new(@client, klass.resource_name => res, :association => instance_association)
          end

          instance_variable_set("@#{resource}", loaded_resources)
        elsif klass.ancestors.include?(DataResource)
          collection = Zendesk::Collection.new(@client, klass, instance_opts.merge(:association => instance_association))
          instance_variable_set("@#{resource}", collection)
        end
      end

      define_method "#{resource}=" do |arg|
        instance_association = Association.new(class_level_association.merge(:parent => self))

        if arg.is_a?(Array)
          res = send(resource)

          arg.map! do |attr| 
            if attr.is_a?(Hash)
              attr.merge!(:association => instance_association)
            else
              attr = { :id => attr, :association => instance_association }
            end

            klass.new(@client, attr)
          end

          res.clear.push(*arg)
        else
          arg.association = instance_association
          instance_variable_set("@#{resource}", arg)
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

  class << self
    # Revert Rails' overwrite of const_missing
    if method_defined?(:const_missing_without_dependencies)
      alias :const_missing :const_missing_without_dependencies
    end

    # Allows using has and has_many without having class defined yet
    # Guesses at Resource, if it's anything else and the class is later
    # reopened under a different superclass, an error will be thrown
    def get_class(resource)
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
end

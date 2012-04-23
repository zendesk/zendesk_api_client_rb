require 'hashie'

module Zendesk
  class Resource 
    class << self
      %w{put post delete}.each do |verb|
        class_eval <<-END
        def #{verb}(method, opts = {})
          define_method method do
            return @#{verb} if @#{verb} && !opts[:reload]
            response = @client.connection.send("#{verb}", "\#{path}/\#{id}/\#{method}.json")

            if response.status == 200
              if (resources = response.body[self.class.resource_name]) &&
                (res = resources.find {|res| res["id"] == id})
                  @attributes = Hashie::Mash.new(res)
              end

              true
            else
              # Error
            end
          end
        end
        END
      end

  def singular_resource_name
    @singular_resource_name ||= to_s.split("::").last.snakecase
  end

  def resource_name
    @resource_name ||= singular_resource_name.plural
  end

  def has(resource, opts = {})
    klass = Zendesk.get_class(opts.delete(:class)) || Zendesk.get_class(resource)

    define_method resource do |*args|
      options = args.last.is_a?(Hash) ? args.pop : {}
      return instance_variable_get("@#{resource}") if instance_variable_defined?("@#{resource}") && !options[:reload]

      if res_id = @attributes["#{resource}_id"]
        klass.find(@client, res_id)
      elsif (res = @attributes[resource.to_s]) && res.is_a?(Hash)
        klass.new(@client, res)
      else
        response = @client.connection.get("#{path}/#{id}/#{opts[:path] || resource}.json")

        if response.status == 200
          # XXX move path up too?
          instance_variable_set("@#{resource}", klass.new(@client, response.body, @path.dup.push(self.id).push(resource.to_s)))
        else
          nil
        end
        # Grab it
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

        Zendesk::Collection.new(@client, klass.resource_name, { klass.resource_name => collection })
      elsif (res = @attributes[resource.to_s]) && res.any?
        Zendesk::Collection.new(@client, klass.resource_name, { klass.resource_name => res })
      else
        response = @client.connection.get("#{path}/#{id}/#{opts[:path] || resource}.json")

        if response.status == 200
          # XXX move path up too?
          new_path = @path.dup
          new_path.push(id).push(resource.to_s) unless opts[:set_path] == false
          instance_variable_set("@#{resource}", Zendesk::Collection.new(@client, klass.resource_name, response.body, new_path))
        else
          []
        end
      end
    end
  end

  def find(client, id, opts = {})
    response = client.connection.get("#{resource_name}/#{id}.json") do |req|
      req.params = opts
    end

    if response.status == 200
      new(client, response.body[singular_resource_name], [resource_name])
    else
      # log error?
      nil
    end
  end

  def destroy(client, id)
    response = client.connection.delete("#{resource_name}/#{id}.json")
    response.status == 200
  end

  def create(client, attributes = {}, path = "")
    path = resource_name if path.empty?
    response = client.connection.post("#{path}.json")

    if response.status == 200
      new(client, response.body[singular_resource_name], [resource_name])
    else
      # log error?
      nil
    end
  end
end

    attr_reader :attributes
    def initialize(client, attributes, path = [])
      @client, @attributes, @path = client, Hashie::Mash.new(attributes), path
      @destroyed = false
    end

    def method_missing(*args)
      attributes.send(*args)
    end

    def path
      @path.join("/")
    end

    def id
      attributes.id
    end

    def save
      return false if @destroyed

      json = attributes.to_json
      response = @client.connection.put("#{path}/#{id}.json")

      if response.status != 200
        # Error handling
      else
        true
      end
    end

    def destroy
      response = @client.connection.delete("#{path}/#{id}.json")

      if response.status != 200
      else
        @destroyed = true
        true
      end
    end
  end

  private

  # Allows using has and has_many without having class defined yet
  def self.get_class(resource)
    return false if resource.nil?
    res = resource.to_s.upper_camelcase

    begin
      const_get(res)
    rescue NameError
      const_set(res, Class.new(Resource))
    end
  end
end

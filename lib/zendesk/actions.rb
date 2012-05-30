module Zendesk
  module Save
    # If this resource hasn't been deleted, then create or save it.
    # Executes a POST if it is a {#new_record?}, otherwise a PUT.
    # Merges returned attributes on success.
    # @return [Boolean] Success?
    def save
      return false if respond_to?(:destroyed?) && destroyed?

      if new_record?
        method = :post
        req_path = path
      else
        method = :put
        req_path = url || path
      end

      self.class.associations.each do |assoc|
        if assoc[:save]
          assoc_id = "#{assoc[:name]}_id"
          singular_assoc_ids = "#{assoc[:name].to_s.singular}_ids"
          assoc_obj = send(assoc[:name])
          next unless assoc_obj
          assoc_obj.save if assoc_obj.respond_to?(:save)

          if has_key?(assoc_id)
            attributes[assoc_id] = assoc_obj.id
          elsif has_key?(singular_assoc_ids)
            attributes[singular_assoc_ids] = assoc_obj.map(&:id)
          else
            attributes[assoc[:name]] = assoc_obj.is_a?(Collection) ? assoc_obj.map(&:to_param) : assoc_obj.to_param
          end
        end
      end

      response = @client.connection.send(method, req_path) do |req|
        req.body = if self.class.unnested_params
          attributes.changes
        else
          {self.class.singular_resource_name.to_sym => attributes.changes}
        end
      end

      @attributes.replace @attributes.deep_merge(response.body[self.class.singular_resource_name] || {})
      @attributes.clear_changes
      true
    end
  end

  module Read
    extend Rescue

    # Finds a resource by an id and any options passed in.
    # A custom path to search at can be passed into opts. It defaults to the {DataResource.resource_name} of the class. 
    # @param [Client] client The {Client} object to be used
    # @param [Hash] opts Any additional GET parameters to be added
    def find(client, opts = {})
      association = opts.delete(:association) || Association.new(:class => self)

      response = client.connection.get(association.generate_path(opts)) do |req|
        req.params = opts
      end

      new(client, response.body[singular_resource_name])
    end

    rescue_client_error :find
  end

  module Create
    extend Rescue
    include Save

    # Create a resource given the attributes passed in.
    # @param [Client] client The {Client} object to be used
    # @param [Hash] attributes The attributes to create.
    def create(client, attributes = {})
      Zendesk::Client.check_deprecated_namespace_usage attributes, singular_resource_name
      resource = new(client, attributes)
      resource.save
      resource
    end

    rescue_client_error :create
  end

  module Destroy
    extend Rescue

    def self.included(klass)
      klass.extend(ClassMethod)
    end

    # Has this object been deleted?
    def destroyed?
      @destroyed ||= false
    end

    # If this resource hasn't already been deleted, then do so.
    # @return [Boolean] Successful?
    def destroy
      return false if destroyed? || new_record?

      response = @client.connection.delete(url || path)

      @destroyed = true # FIXME always returns true
    end

    rescue_client_error :destroy, :with => false

    module ClassMethod
      extend Rescue

      # Deletes a resource given the id passed in.
      # @param [Client] client The {Client} object to be used
      # @param [Number] id The id to DELETE.
      # @param [Hash] opts The optional parameters to pass. Defaults to {}
      def destroy(client, opts = {})
        association = opts.delete(:association) || Association.new(:class => self)

        client.connection.delete(association.generate_path(opts)) do |req|
          req.params = opts
        end

        true
      end

      rescue_client_error :destroy, :with => false
    end
  end

  module Update
    extend Rescue
    include Save

    def self.included(klass)
      klass.extend(ClassMethod)
    end

    rescue_client_error :save, :with => false

    module ClassMethod
      extend Rescue

      # Updates  a resource given the id passed in.
      # @param [Client] client The {Client} object to be used
      # @param [Number] id The id to DELETE.
      # @param [String] path The optional path to use. Defaults to {DataResource.resource_name}. 
      def update(client, attributes = {})
        association = attributes.delete(:association) || Association.new(:class => self)

        client.connection.put(association.generate_path(attributes)) do |req|
          req.body = attributes
        end

        true
      end

      rescue_client_error :update, :with => false
    end
  end
end

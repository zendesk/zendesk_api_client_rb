module ZendeskAPI
  module Save
    # If this resource hasn't been deleted, then create or save it.
    # Executes a POST if it is a {Data#new_record?}, otherwise a PUT.
    # Merges returned attributes on success.
    # @return [Boolean] Success?
    def save!(options = {})
      return false if respond_to?(:destroyed?) && destroyed?

      if new_record? && !options[:force_update]
        method = :post
        req_path = path
      else
        method = :put
        req_path = url || path
      end

      req_path = options[:path] if options[:path]

      save_associations

      @response = @client.connection.send(method, req_path) do |req|
        req.body = attributes_for_save.merge(@global_params)
      end

      @attributes.replace @attributes.deep_merge(@response.body[self.class.singular_resource_name] || {})
      @attributes.clear_changes
      clear_associations
      true
    end

    # Saves, returning false if it fails and attaching the errors
    def save(options={})
      save!(options)
    rescue ZendeskAPI::Error::RecordInvalid => e
      @errors = e.errors
      false
    rescue ZendeskAPI::Error::ClientError
      false
    end

    # Removes all cached associations
    def clear_associations
      self.class.associations.each do |association_data|
        name = association_data[:name]
        instance_variable_set("@#{name}", nil) if instance_variable_defined?("@#{name}")
      end
    end

    # Saves associations
    # Takes into account inlining, collections, and id setting on the parent resource.
    def save_associations
      self.class.associations.each do |association_data|
        association_name = association_data[:name]
        next unless send("#{association_name}_used?") && association = send(association_name)

        inline_creation = association_data[:inline] == :create && new_record?
        changed = association.is_a?(Collection) || !association.changes.empty?

        if association.respond_to?(:save) && changed && !inline_creation && association.save
          self.send("#{association_name}=", association) # set id/ids columns
        end

        if (association_data[:inline] == true || inline_creation) && association.changed?
          attributes[association_name] = (association.is_a?(Collection) ? association.map(&:to_param) : association.to_param)
        end
      end
    end
  end

  module Read
    def self.extended(klass)
      klass.send(:include, ZendeskAPI::Sideloading)
    end

    # Finds a resource by an id and any options passed in.
    # A custom path to search at can be passed into opts. It defaults to the {Data.resource_name} of the class.
    # @param [Client] client The {Client} object to be used
    # @param [Hash] options Any additional GET parameters to be added
    def find!(client, options = {})
      @client = client # so we can use client.logger in rescue

      raise ArgumentError, "No :id given" unless options[:id] || options["id"] || ancestors.include?(SingularResource)
      association = options.delete(:association) || Association.new(:class => self)

      includes = Array(options[:include])
      options[:include] = includes.join(",") if includes.any?

      response = client.connection.get(association.generate_path(options)) do |req|
        req.params = options
      end

      new(client, response.body[singular_resource_name]).tap do |resource|
        resource.set_includes(resource, includes, response.body)
      end
    end

    # Finds, returning nil if it fails
    def find(client, options = {})
      find!(client, options)
    rescue ZendeskAPI::Error::ClientError => e
      nil
    end
  end

  module Create
    include Save

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Create a resource given the attributes passed in.
      # @param [Client] client The {Client} object to be used
      # @param [Hash] attributes The attributes to create.
      def create!(client, attributes = {})
        ZendeskAPI::Client.check_deprecated_namespace_usage attributes, singular_resource_name
        new(client, attributes).tap(&:save!)
      end

      def create(client, attributes = {})
        create!(client, attributes)
      rescue ZendeskAPI::Error::ClientError
        nil
      end
    end
  end

  module Destroy
    def self.included(klass)
      klass.extend(ClassMethod)
    end

    # Has this object been deleted?
    def destroyed?
      @destroyed ||= false
    end

    # If this resource hasn't already been deleted, then do so.
    # @return [Boolean] Successful?
    def destroy!
      return false if destroyed? || new_record?
      @client.connection.delete(url || path)
      @destroyed = true
    end

    def destroy
      destroy!
    rescue ZendeskAPI::Error::ClientError
      false
    end

    module ClassMethod
      # Deletes a resource given the id passed in.
      # @param [Client] client The {Client} object to be used
      # @param [Hash] opts The optional parameters to pass. Defaults to {}
      def destroy!(client, opts = {})
        @client = client # so we can use client.logger in rescue
        association = opts.delete(:association) || Association.new(:class => self)

        client.connection.delete(association.generate_path(opts)) do |req|
          req.params = opts
        end

        true
      end

      def destroy(client, attributes = {})
        destroy!(client, attributes)
      rescue ZendeskAPI::Error::ClientError
        false
      end
    end
  end

  module Update
    include Save

    def self.included(klass)
      klass.extend(ClassMethod)
    end

    module ClassMethod
      # Updates  a resource given the id passed in.
      # @param [Client] client The {Client} object to be used
      # @param [Hash] attributes The attributes to update. Default to {}
      def update(client, attributes = {})
        update!(client, attributes)
      rescue ZendeskAPI::Error::ClientError
        false
      end

      def update!(client, attributes = {})
        ZendeskAPI::Client.check_deprecated_namespace_usage attributes, singular_resource_name
        resource = new(client, { :id => attributes.delete(:id), :global => attributes.delete(:global) })
        resource.attributes.merge!(attributes)
        resource.save!(:force_update => resource.is_a?(SingularResource))
        resource
      end
    end
  end
end

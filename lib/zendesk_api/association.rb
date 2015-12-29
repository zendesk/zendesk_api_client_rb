module ZendeskAPI
  # Represents an association between two resources
  # @private
  class Association
    # Options to pass in
    # * name - Required
    #
    # * singular_key - Required
    # * plural_key - Required
    # * include_key - Required
    # * association_class - Required
    #
    # * parent_key - Required
    def initialize(options = {})
      @options = options
    end

    # Tries to place side loads onto given resources.
    def side_load(resources, side_loads)
      resources.each do |resource|
        if resource.key?(@options[:plural_key]) # Grab associations from child_ids field on resource
          side_load_from_child_ids(resource, side_loads)
        elsif resource.key?(@options[:singular_key])
          side_load_from_child_or_parent_id(resource, side_loads)
        else # Grab associations from parent_id field from multiple child resources
          side_load_from_parent_id(resource, side_loads)
        end
      end
    end

    private

    def _side_load(resource, side_loads)
      resource.wrap_plural_resource(side_loads, @options)
    end

    def side_load_from_parent_id(resource, side_loads)
      resource.public_send("#{@options[:name]}=", _side_load(resource, side_loads.select {|side_load|
        side_load[@options[:parent_key]] == resource.id
      }))
    end

    def side_load_from_child_ids(resource, side_loads)
      ids = resource.public_send(@options[:plural_key])

      resource.send("#{@options[:name]}=", _side_load(resource, side_loads.select {|side_load|
        ids.include?(side_load[@options[:include_key]])
      }))
    end

    def side_load_from_child_or_parent_id(resource, side_loads)
      # Either grab association from child_id field on resource or parent_id on child resource
      if resource.key?(@options[:singular_key])
        id = resource.public_send(@options[:singular_key])
        include_key = @options[:include_key]
      else
        id = resource.id
        include_key = @options[:parent_key]
      end

      return unless id

      side_load = side_loads.detect do |side_load|
        id == side_load[include_key.to_s]
      end

      resource.send("#{@options[:name]}=", side_load) if side_load
    end
  end
end

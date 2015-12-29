module ZendeskAPI
  # Represents an association between two resources
  # @private
  class Association
    # Options to pass in
    # * name - Required
    # * sideload - Required
    #   * key - Optional (defaults to id)
    #   * from - Required
    #   * using - Required
    def initialize(options = {})
      @options = options
      @options[:sideload] = { key: :id }.merge(@options[:sideload])
    end

    # Tries to place side loads onto given resources.
    def side_load(resources, side_loads)
      resources.each do |resource|
        case @options[:sideload][:from]
        when :parent_id
          side_load_from_parent_id(resource, side_loads)
        when :parent_ids
          side_load_from_parent_ids(resource, side_loads)
        when :child_id
          side_load_from_child_id(resource, side_loads)
        when :child_ids
          side_load_from_child_ids(resource, side_loads)
        else
          # raise
        end
      end
    end

    private

    def _side_load(resource, side_loads)
      resource.wrap_plural_resource(side_loads, @options)
    end

    def side_load_from_parent_ids(resource, side_loads)
      resource.public_send("#{@options[:name]}=", _side_load(resource, side_loads.select {|side_load|
        side_load[@options[:sideload][:using].to_s] == resource.public_send(@options[:sideload][:key])
      }))
    end

    def side_load_from_parent_id(resource, side_loads)
      id = resource.public_send(@options[:sideload][:key])

      return unless id

      side_load = side_loads.detect do |side_load|
        id == side_load[@options[:sideload][:using].to_s]
      end

      resource.public_send("#{@options[:name]}=", side_load) if side_load
    end

    def side_load_from_child_ids(resource, side_loads)
      ids = resource.public_send(@options[:sideload][:using])

      resource.public_send("#{@options[:name]}=", _side_load(resource, side_loads.select {|side_load|
        ids.include?(side_load[@options[:sideload][:key].to_s])
      }))
    end

    def side_load_from_child_id(resource, side_loads)
      id = resource.public_send(@options[:sideload][:using])

      return unless id

      side_load = side_loads.detect do |side_load|
        id == side_load[@options[:sideload][:key].to_s]
      end

      resource.public_send("#{@options[:name]}=", side_load) if side_load
    end
  end
end

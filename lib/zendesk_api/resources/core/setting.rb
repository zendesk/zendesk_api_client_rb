module ZendeskAPI
  class Setting < UpdateResource
    attr_reader :on

    def initialize(client, attributes = {})
      # Try and find the root key
      @on = (attributes.keys.map(&:to_s) - %w{association options}).first

      # Make what's inside that key the root attributes
      attributes.merge!(attributes.delete(@on))

      super
    end

    def new_record?
      false
    end

    def path(options = {})
      super(options.merge(:with_parent => true))
    end

    def attributes_for_save
      { self.class.resource_name => { @on => attributes.changes } }
    end
  end
end

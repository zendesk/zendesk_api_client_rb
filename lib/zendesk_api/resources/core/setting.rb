module ZendeskAPI
  class Setting < UpdateResource
    self.resource_name = 'settings'
    self.singular_resource_name = 'settings'

    self.resource_paths = [
      'users/me/settings',
      'account/settings'
    ]

    attr_reader :on

    def initialize(client, attributes = {})
      # Try and find the root key
      # TODO?
      @on = (attributes.keys.map(&:to_s) - %w{association options}).first

      # Make what's inside that key the root attributes
      attributes.merge!(attributes.delete(@on))

      super
    end

    def new_record?
      false
    end

    def attributes_for_save
      { self.class.resource_name => { @on => attributes.changes } }
    end
  end
end

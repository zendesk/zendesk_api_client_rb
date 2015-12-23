module ZendeskAPI
  module Voice
    class Address < Resource
      self.resource_name = 'addresses'
      self.singular_resource_name = 'address'

      namespace "channels/voice"
    end
  end
end

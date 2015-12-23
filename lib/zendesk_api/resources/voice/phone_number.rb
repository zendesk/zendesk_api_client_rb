module ZendeskAPI
  module Voice
    class PhoneNumber < Resource
      self.resource_name = 'phone_numbers'
      self.singular_resource_name = 'phone_number'

      namespace "channels/voice"
    end
  end
end

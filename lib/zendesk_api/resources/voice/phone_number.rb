module ZendeskAPI
  module Voice
    class PhoneNumber < Resource
      self.resource_name = 'phone_numbers'
      self.singular_resource_name = 'phone_number'

      self.collection_paths = ['channels/voice/phone_numbers']
      self.resource_paths = ['channels/voice/phone_numbers/%{id}']

      namespace "channels/voice"
    end
  end
end

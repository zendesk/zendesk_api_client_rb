module ZendeskAPI
  module Voice
    class Greeting < Resource
      self.resource_name = 'greetings'
      self.singular_resource_name = 'greeting'

      namespace "channels/voice"
    end
  end
end

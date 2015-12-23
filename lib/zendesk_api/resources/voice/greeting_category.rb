module ZendeskAPI
  module Voice
    class GreetingCategory < Resource
      self.resource_name = 'greeting_categories'
      self.singular_resource_name = 'greeting_category'

      namespace "channels/voice"
    end
  end
end

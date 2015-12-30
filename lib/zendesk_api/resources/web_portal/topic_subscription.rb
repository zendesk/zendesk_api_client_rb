module ZendeskAPI
  class TopicSubscription < Resource
    self.resource_name = 'topic_subscriptions'
    self.singular_resource_name = 'topic_subscription'

    self.collection_paths = ['topic_subscriptions']
    self.resource_paths = ['topic_subscriptions/%{id}']

    has :topic, class: 'Topic'
    has :user, class: 'User'
  end
end

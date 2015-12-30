module ZendeskAPI
  class ForumSubscription < Resource
    self.resource_name = 'forum_subscriptions'
    self.singular_resource_name = 'forum_subscription'

    self.collection_paths = [
      'forum_subscriptions',
      'forums/%{forum_id}/subscriptions', # TODO!?
      'users/%{user_id}/forum_subscriptions', # TODO!?
    ]

    self.resource_paths = ['forum_subscriptions/%{id}']

    has :forum, class: 'Forum'
    has :user, class: 'User'
  end

  class Forum < Resource
    self.resource_name = 'forums'
    self.singular_resource_name = 'forum'

    self.resource_paths = ['forums/%{id}']
    self.collection_paths = ['forums']

    has :category, class: 'Category'
    has :organization, class: 'Organization'
    has :locale, class: 'Locale'

    has_many :topics, class: 'Topic', path: 'forums/%{id}/topics'
    has_many :subscriptions, class: 'ForumSubscription', path: 'forums/%{id}/subscriptions'
  end
end

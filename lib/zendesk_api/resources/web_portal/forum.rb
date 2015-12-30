module ZendeskAPI
  class ForumSubscription < Resource
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
    has_many :subscriptions, class: 'ForumSubscription'
  end
end

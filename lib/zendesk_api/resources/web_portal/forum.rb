module ZendeskAPI
  class ForumSubscription < Resource
    has :forum, class: 'Forum'
    has :user, class: 'User'
  end

  class Forum < Resource
    has :category, class: 'Category'
    has :organization, class: 'Organization'
    has :locale, class: 'Locale'

    has_many :topics, class: 'Topic'
    has_many :subscriptions, class: 'ForumSubscription'
  end
end

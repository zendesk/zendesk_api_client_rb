module Zendesk
  class Forum < Resource
    has :category
    has :organization
    has :locale

    has_many :topics
    has_many :subscriptions, :class => :forum_subscription
  end

  class Category < Resource
    has_many :forums
  end

  class TopicSubscription < Resource
    has_parent :topic
    has :user
  end

  class ForumSubscription < Resource
    has_parent :forum
    has :user
  end

  class TopicComment < Resource
    has_parent :topic
    has :user
    has_many :attachments
  end

  class Topic < Resource
    has_many :comments, :class => :topic_comment
    has_many :subscriptions, :class => :topic_subscription
    has_many :votes, :only => true, :singular => true
  end

  class Vote < Resource
    has_parent :topic
    has :user
  end
end

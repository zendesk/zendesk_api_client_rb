module Zendesk
  class Forum < Resource
    has :category
    has :organization
    has :locale

    has_many :topics, :set_path => false
    has_many :subscriptions, :class => :forum_subscription, :set_path => false
  end

  class Category < Resource
    has_many :forums, :set_path => false
  end

  class TopicSubscription < Resource
    has :topic
    has :user
  end

  class ForumSubscription < Resource
    has :forum
    has :user
  end

  class TopicComment < Resource
    has :topic
    has :user
    has_many :attachments
  end

  class Topic < Resource
    has_many :comments, :class => :topic_comment 
    has_many :subscriptions, :class => :topic_subscription, :set_path => false
    has_many :votes
  end
end

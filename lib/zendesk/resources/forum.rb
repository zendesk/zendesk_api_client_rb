module Zendesk
  class Forum < Resource
    class ForumSubscription < Resource
      has :forum
      has :user
    end

    has :category
    has :organization
    has :locale

    has_many :topics
    has_many :subscriptions, :class => :forum_subscription
  end

  class Category < Resource
    has_many :forums
  end

  class Topic < Resource
    class TopicComment < Resource
      has :topic
      has :user
      has_many :attachments
    end

    class Vote < Resource
      has :topic
      has :user
    end

    class TopicSubscription < Resource
      has :topic
      has :user
    end

    has_many :comments, :class => :topic_comment
    has_many :subscriptions, :class => :topic_subscription
    has_many :votes
  end
end

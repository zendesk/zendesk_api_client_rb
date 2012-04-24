module Zendesk
  class Forum < Resource
    has :category
    has :organization
    has :locale

    has_many :topics
    has_many :subscriptions, :class => :forum_subscription

    allow_parameters :category_id, :forum =>
      [:name, :description, :organization_id, :locale_id, :locked, :position, :forum_type, :access]
  end

  class Category < Resource
    has_many :forums
    
    allow_parameters :category => [:name, :description, :position]
  end

  class TopicSubscription < Resource
    has :topic
    has :user
    
    allow_parameters :topic_id, :user_id
  end

  class ForumSubscription < Resource
    has :forum
    has :user

    allow_parameters :forum_id, :user_id
  end

  class TopicComment < Resource
    has :topic
    has :user
    has_many :attachments

    allow_parameters :topic_id, :user_id, :topic_comment => [:body, :informative]
  end

  class Topic < Resource
    has_many :comments, :class => :topic_comment 
    has_many :subscriptions, :class => :topic_subscription
    has_many :votes, :set_path => true

    allow_parameters :user_id, :forum_id,
      :topic => [:title, :body, :submitter_id, :updater_id, :forum_id, :is_locked, :is_pinned, :is_highlighted, :position, :tags]
  end

  class Vote < Resource
    allow_parameters :topic_id, :user_id
  end
end

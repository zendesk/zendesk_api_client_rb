module Zendesk
  class ForumSubscription < Resource
    has :forum
    has :user
  end

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
    has :topic
    has :user
  end

  class Topic < Resource
    class TopicComment < Resource
      has :topic
      has :user
      has_many :attachments
    end

    class TopicVote < SingularResource
      has :topic
      has :user
    end

    has_many :comments, :class => :topic_comment
    has_many :subscriptions, :class => :topic_subscription
    has :vote, :class => :topic_vote 

    def votes(opts = {})
      return @votes if @votes && !opts[:reload]

      association = Zendesk::Association.new(:class => Topic::TopicVote, :parent => self, :path => 'votes')
      @votes = Zendesk::Collection.new(@client, Topic::TopicVote, opts.merge(:association => association))
    end
  end
end

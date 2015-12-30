module ZendeskAPI
  class TopicSubscription < Resource
    self.resource_name = 'topic_subscriptions'
    self.singular_resource_name = 'topic_subscription'

    self.collection_paths = ['topic_subscriptions']
    self.resource_paths = ['topic_subscriptions/%{id}']

    has :topic, class: 'Topic'
    has :user, class: 'User'
  end

  class TopicComment < Resource
    self.resource_name = 'topic_comments'
    self.singular_resource_name = 'topic_comment'

    self.collection_paths = [
      'topics/%{topic_id}/comments',
      'users/%{user_id}/topic_comments'
    ]

    self.resource_paths = [
      'topics/%{topic_id}/comments/%{id}',
      'users/%{user_id}/topic_comments/%{id}'
    ]

    has :topic, class: 'Topic'
    has :user, class: 'User'
    has_many :attachments, class: 'Attachment', path: '' # TODO
    has_many :uploads, class: 'Attachment', inline: true, path: '' # TODO

    def self.import!(client, attributes)
      new(client, attributes).tap do |comment|
        comment.save!(:path => 'import/' + comment.path)
      end
    end

    def self.import(client, attributes)
      comment = new(client, attributes)
      return unless comment.save(:path => 'import/' + comment.path)
      comment
    end
  end

  class TopicVote < DataResource
    include Read
    include Create
    include Destroy

    self.resource_name = 'topic_votes'
    self.singular_resource_name = 'topic_vote'

    self.collection_paths = [
      'topics/%{topic_id}/votes',
      'users/%{user_id}/topic_votes'
    ]

    self.resource_paths = [
      'topics/%{topic_id}/vote'
    ]

    has :topic, class: 'Topic'
    has :user, class: 'User'

    protected

    def save_options
      [:post, path.format(attributes)]
    end

    def attributes_for_save
      attributes.changes
    end
  end

  class Topic < Resource
    self.resource_name = 'topics'
    self.singular_resource_name = 'topic'

    self.collection_paths = ['topics']
    self.resource_paths = ['topics/%{id}']

    has :forum, class: 'Forum'
    has_many :comments, class: 'TopicComment', path: 'topics/%{id}/comments'
    has_many :subscriptions, class: 'TopicSubscription', path: 'topics/%{id}/subscriptions'
    has :vote, class: 'TopicVote'
    has_many :votes, class: 'TopicVote', path: 'topics/%{id}/votes'
    has_many :tags, class: 'Tag', extend: 'Tag::Update', inline: :create, path: '' # TODO
    has_many :attachments, class: 'Attachment', path: 'attachments' # TODO
    has_many :uploads, class: 'Attachment', inline: true, path: '' # TODO

    def self.import!(client, attributes)
      new(client, attributes).tap do |topic|
        topic.save!(:path => "import/topics")
      end
    end

    def self.import(client, attributes)
      topic = new(client, attributes)
      return unless topic.save(:path => "import/topics")
      topic
    end
  end
end

module ZendeskAPI
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

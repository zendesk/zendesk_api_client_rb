module ZendeskAPI
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
end

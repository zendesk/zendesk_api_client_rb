module ZendeskAPI
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
end

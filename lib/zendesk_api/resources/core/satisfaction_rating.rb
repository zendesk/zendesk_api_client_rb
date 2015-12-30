module ZendeskAPI
  class SatisfactionRating < ReadResource
    self.resource_name = 'satisfaction_ratings'
    self.singular_resource_name = 'satisfaction_rating'

    self.collection_paths = [
      'satisfaction_ratings',
      'satisfaction_ratings/received'
    ]

    self.resource_paths = ['satisfaction_ratings/%{id}']

    has :assignee, class: 'User'
    has :requester, class: 'User'
    has :ticket, class: 'Ticket'
    has :group, class: 'Group'
  end
end

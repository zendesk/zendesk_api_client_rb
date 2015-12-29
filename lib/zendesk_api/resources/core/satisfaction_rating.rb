module ZendeskAPI
  class SatisfactionRating < ReadResource
    has :assignee, class: 'User'
    has :requester, class: 'User'
    has :ticket, class: 'Ticket'
    has :group, class: 'Group'
  end
end

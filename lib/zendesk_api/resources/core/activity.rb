module ZendeskAPI
  class Activity < Resource
    has :user, class: 'User'
    has :actor, class: 'User'
  end
end

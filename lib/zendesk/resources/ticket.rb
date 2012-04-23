module Zendesk
  class Ticket < Resource
    has :submitter, :class => :user
    has :assignee, :class => :user
    has :recipient, :class => :user
    has_many :collaborators, :class => :user
    has :group
    has :forum_topic, :class => :topic
    has :organization
  end

  class TicketField < Resource; end

  class View < Resource
    # Owner => { id, type }
    # But if account, what to do?
  end
end

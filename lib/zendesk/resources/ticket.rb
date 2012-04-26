module Zendesk
  class Audit < DataResource; end
  class TicketField < Resource; end

  class Ticket < Resource
    has :submitter, :class => :user
    has :assignee, :class => :user
    has :recipient, :class => :user
    has_many :collaborators, :class => :user
    has_many :audits
    has :group
    has :forum_topic, :class => :topic
    has :organization
  end

  class View < DataResource
    # Owner => { id, type }
    # But if account, what to do?
  end
end

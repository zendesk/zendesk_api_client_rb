module Zendesk
  class TicketField < Resource; end
  class Audit < DataResource; end
  class TicketComment < Data; end
  class TicketMetric < ReadResource; end

  class Ticket < Resource
    class Audit < DataResource; end

    has :requester, :class => :user
    has :submitter, :class => :user
    has :assignee, :class => :user
    has :recipient, :class => :user
    has_many :collaborators, :class => :user
    has_many :audits
    has_many :metrics, :class => :ticket_metric
    has :group
    has :forum_topic, :class => :topic
    has :organization

    has_many :uploads, :class => :attachment, :save => true
    has :comment, :class => :ticket_comment, :save => true
  end

  class SuspendedTicket < ReadResource
    extend Destroy
    put :recover
  end

  class View < DataResource
    # Owner => { id, type }
    # But if account, what to do?
  end
end

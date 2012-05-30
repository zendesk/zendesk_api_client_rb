module Zendesk
  class TicketField < Resource; end
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
    has :metrics, :class => :ticket_metric
    has :group
    has :forum_topic, :class => :topic
    has :organization

    has_many :uploads, :class => :attachment, :save => true
    has :comment, :class => :ticket_comment, :save => true

    def self.incremental_export(client, start_time)
      Zendesk::Collection.new(client, self, :path => "exports/tickets.json?start_time=#{start_time.to_i}")
    end

    def self.import(client, attributes)
      ticket = new(client, attributes)
      return unless ticket.save(:path => "imports/tickets.json")
      ticket
    end
  end

  class SuspendedTicket < ReadResource
    include Destroy
    put :recover
  end

  class View < DataResource
    # Owner => { id, type }
    # But if account, what to do?
  end
end

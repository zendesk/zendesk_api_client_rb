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

    # Gets a incremental export of tickets from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {Ticket}
    def self.incremental_export(client, start_time)
      Zendesk::Collection.new(client, self, :path => "exports/tickets?start_time=#{start_time.to_i}")
    end

    # Imports a ticket through the imports/tickets endpoint
    # @param [Client] client The {Client} object to be used
    # @param [Hash] attributes The attributes to create.
    # @return [Ticket] Created object or nil
    def self.import(client, attributes)
      ticket = new(client, attributes)
      return unless ticket.save(:path => "imports/tickets")
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

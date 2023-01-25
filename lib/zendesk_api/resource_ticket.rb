module ZendeskAPI
  # https://developer.zendesk.com/api-reference/ticketing/tickets/tickets/
  class Ticket < Resource
    extend CreateMany
    extend UpdateMany
    extend DestroyMany

    # Unlike other attributes, "comment" is not a property of the ticket,
    # but is used as a "comment on save", so it should be kept unchanged,
    # See https://github.com/zendesk/zendesk_api_client_rb/issues/321
    def attribute_changes
      attributes.changes.merge("comment" => attributes["comment"])
    end

    # https://developer.zendesk.com/api-reference/ticketing/tickets/ticket_audits/
    class Audit < DataResource
      # https://developer.zendesk.com/api-reference/ticketing/tickets/ticket_audits/
      class Event < Data
        has :author, :class => User
      end

      put :trust

      # need this to support SideLoading
      has :author, :class => User

      has_many Event
    end

    # https://developer.zendesk.com/api-reference/ticketing/tickets/ticket_comments/
    class Comment < DataResource
      include Save

      has_many :uploads, :class => Attachment, :inline => true
      has :author, :class => User

      def save
        if new_record?
          save_associations
          true
        else
          false
        end
      end

      alias save! save
    end

    # https://developer.zendesk.com/api-reference/ticketing/ticket-management/satisfaction_ratings/
    class SatisfactionRating < CreateResource
      class << self
        alias resource_name singular_resource_name
      end
    end

    put :mark_as_spam
    post :merge

    has :requester, :class => User, :inline => :create
    has :submitter, :class => User
    has :assignee, :class => User

    has_many :collaborators, :class => User, :inline => true, :extend => (Module.new do
      def to_param
        map(&:id)
      end
    end)

    has_many Audit
    has :metrics, :class => TicketMetric
    has Group
    has Organization
    has Brand
    has :related, :class => TicketRelated

    has Comment, :inline => true
    has_many Comment

    has :last_comment, :class => Comment, :inline => true
    has_many :last_comments, :class => Comment, :inline => true

    has_many Tag, :extend => Tag::Update, :inline => :create

    has_many :incidents, :class => Ticket

    # Gets a incremental export of tickets from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {Ticket}
    def self.incremental_export(client, start_time)
      ZendeskAPI::Collection.new(client, self, :path => "incremental/tickets?start_time=#{start_time.to_i}")
    end

    # Imports a ticket through the imports/tickets endpoint using save!
    # @param [Client] client The {Client} object to be used
    # @param [Hash] attributes The attributes to create.
    # @return [Ticket] Created object or nil
    def self.import!(client, attributes)
      new(client, attributes).tap do |ticket|
        ticket.save!(:path => "imports/tickets")
      end
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
end

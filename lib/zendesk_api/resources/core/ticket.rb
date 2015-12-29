module ZendeskAPI
  class TicketField < Resource; end

  class TicketMetric < DataResource
    include Read
  end

  class TicketRelated < DataResource; end

  class TicketEvent < DataResource
    class Event < Data; end

    has_many :child_events, class: 'TicketEvent::Event'
    has :ticket, class: 'Ticket'
    has :updater, class: 'User'

    # Gets a incremental export of ticket events from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {TicketEvent}
    def self.incremental_export(client, start_time)
      ZendeskAPI::Collection.new(client, self, :path => "incremental/ticket_events?start_time=#{start_time.to_i}")
    end
  end

  class Ticket < Resource
    extend CreateMany
    extend UpdateMany
    extend DestroyMany

    self.resource_name = 'tickets'
    self.singular_resource_name = 'ticket'
    self.collection_paths = ['tickets']
    self.resource_paths = ['tickets/%{id}']

    class Audit < DataResource
      class Event < Data
        has :author, class: 'User'
      end

      put :trust

      # need this to support SideLoading
      has :author, class: 'User'

      has_many :events, class: 'Ticket::Audit::Event'
    end

    class Comment < DataResource
      include Save

      has_many :uploads, class: 'Attachment', inline: true
      has :author, class: 'User'

      # TODO
      def save
        if new_record?
          save_associations
          true
        else
          false
        end
      end

      alias :save! :save
    end

    class SatisfactionRating < CreateResource
      # TODO?
      class << self
        alias :resource_name :singular_resource_name
      end
    end

    put :mark_as_spam
    post :merge

    has :requester, class: 'User', inline: :create
    has :submitter, class: 'User'
    has :assignee, class: 'User'

    has_many :collaborators, class: 'User', inline: true, extend: (Module.new do
      def to_param
        map(&:id)
      end
    end)

    has_many :audits, class: 'Ticket::Audit'
    has :metrics, class: 'TicketMetric'
    has :group, class: 'Group'
    has :forum_topic, class: 'Topic'
    has :organization, class: 'Organization'
    has :brand, class: 'Brand'
    has :related, class: 'TicketRelated'

    has :comment, class: 'Ticket::Comment', inline: true
    has_many :comments, class: 'Ticket::Comment'

    has :last_comment, class: 'Ticket::Comment', inline: true
    has_many :last_comments, class: 'Ticket::Comment', inline: true

    has_many :tags, class: 'Tag', extend: 'Tag::Update', inline: :create

    has_many :incidents, class: 'Ticket'

    # Gets a incremental export of tickets from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {Ticket}
    def self.incremental_export(client, start_time)
      ZendeskAPI::Collection.new(client, self, :path => "exports/tickets?start_time=#{start_time.to_i}")
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

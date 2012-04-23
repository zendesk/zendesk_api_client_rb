module Zendesk
  class Identity < Resource
    put :make_primary
    put :verify
    put :request_verification
  end

  class User < Resource
    has :organization
    has :custom_role
    has_many :identities
    has_many :requested_tickets, :class => :ticket, :path => 'tickets/requested'
    has_many :cced_tickets, :class => :ticket, :path => 'tickets/ccd'

    %w{groups topics topic_comments topic_votes topic_subscriptions forum_subscriptions}.each do |klass|
      has_many klass.to_sym, :set_path => false
    end

    has :crm_data
    has :crm_data_status, :path => 'crm_data/status'
  end

  class Organization < Resource
    has :group
    has_many :tickets
    has_many :users
  end

  class TopicComment < Resource
    has :topic
    has :user
    has_many :attachments
  end

  class Topic < Resource
    has_many :comments, :class => :topic_comment 
    has_many :subscriptions, :class => :topic_subscription, :set_path => false
    has_many :votes
  end

  class Ticket < Resource
    has :submitter, :class => :user
    has :assignee, :class => :user
    has :recipient, :class => :user
    has_many :collaborators, :class => :user
    has :group
    has :forum_topic, :class => :topic
    has :organization
  end

  class TicketField < Resource
  end

  class Macro < Resource
  end

  class View < Resource
    # Owner => { id, type }
    # But if account, what to do?
  end

  class CustomRole < Resource
  end

  class Bookmark < Resource
  end

  class Activity < Resource
    has :user
    has :actor, :class => :user
  end

  class Group < Resource
  end

  class GroupMembership < Resource
    has :user
    has :group
  end

  class Locale < Resource
  end

  class Setting < Resource
    attr_reader :on

    def initialize(client, attributes)
      @on = attributes.first
      super(client, attributes[1])
    end
  end

  class MobileDevice < Resource
    put :clear_badge
  end

  class SatisfactionRating < Resource
    has :assignee, :class => :user 
    has :requester, :class => :user
    has :ticket
    has :group
  end

  class Upload < Resource
  end

  class Category < Resource
    has_many :forums, :set_path => false
  end

  class Forum < Resource
    has :category
    has :organization
    has :locale

    has_many :topics, :set_path => false
    has_many :subscriptions, :class => :forum_subscription, :set_path => false
  end

  class Attachment < Resource
  end


  class TopicSubscription < Resource
    has :topic
    has :user
  end

  class ForumSubscription < Resource
    has :forum
    has :user
  end

  class Playlist
    attr_reader :ticket, :id
    def initialize(client, id)
      @client, @id = client, id
      @ticket = nil

      response = @client.connection.get("views/#{id}/play.json")
      @destroyed = response.status != 302
    end

    def each
      while !@destroyed
        yield self.next
      end
    end

    def next
      return false if @destroyed

      response = @client.connection.get("play/next.json")

      if response.status == 200
        @ticket = Ticket.new(@client, response.body["ticket"], ["tickets"])
        @ticket
      else
        # Depends, but definitely if 204
        @destroyed = response.status == 204 
      end
    end

    def destroy
      response = @client.connection.delete("play.json")
      @destroyed = response.status == 204 
    end
  end
end

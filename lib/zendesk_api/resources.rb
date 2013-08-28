module ZendeskAPI
# @internal The following are redefined later, but needed by some circular resources (e.g. Ticket -> User, User -> Ticket)


  class Ticket < Resource; end
  class Forum < Resource; end
  class User < Resource; end
  class Category < Resource; end

# @internal Begin actual Resource definitions

  class Locale < ReadResource; end

  class CustomRole < DataResource; end
  class Role < DataResource; end
  class Topic < Resource; end
  class Bookmark < Resource; end
  class Ability < DataResource; end
  class Group < Resource; end
  class SharingAgreement < ReadResource; end
  class JobStatus < ReadResource; end

  class Tag < DataResource
    include Update
    include Destroy

    alias :name :id

    def path(opts = {})
      raise "tags must have parent resource" unless association.options.parent
      super(opts.merge(:with_parent => true, :with_id => false))
    end

    def changed?
      true
    end

    def destroy!
      super do |req|
        req.body = attributes_for_save
      end
    end

    module Update
      def _save(method = :save)
        return self unless @resources

        client.connection.post(path) do |req|
          req.body = { :tags => @resources.map(&:id) }
        end

        true
      rescue Faraday::Error::ClientError => e
        if method == :save
          false
        else
          raise e
        end
      end
    end

    def attributes_for_save
      { self.class.resource_name => [id] }
    end
  end

  class Attachment < Data
    def initialize(client, attributes)
      attributes[:file] ||= attributes.delete(:id)

      super
    end

    def save
      upload = Upload.create!(@client, attributes)
      self.token = upload.token
    end

    def to_param
      token
    end
  end

  class Upload < Data
    include Create
    include Destroy

    def id; token; end

    has_many Attachment

    private

    def attributes_for_save
      attributes.changes
    end
  end

  class MobileDevice < Resource
    # Clears this devices' badge
    put :clear_badge
  end

  class Organization < Resource
    has Ability, :inline => true
    has Group

    has_many Ticket
    has_many User
    has_many Tag, :extend => Tag::Update
  end

  class ForumSubscription < Resource
    has Forum
    has User
  end

  class Forum < Resource
    has Category
    has Organization
    has Locale

    has_many Topic
    has_many :subscriptions, :class => ForumSubscription
  end

  class Category < Resource
    has_many Forum
  end

  class TopicSubscription < Resource
    has Topic
    has User
  end

  class TopicComment < Data
    has Topic
    has User
    has_many Attachment
  end

  class Topic < Resource
    class TopicComment < TopicComment
      extend Read

      include Create
      include Update
      include Destroy
    end

    class TopicVote < SingularResource
      has Topic
      has User

      private

      def attributes_for_save
        attributes.changes
      end
    end

    has Forum
    has_many :comments, :class => TopicComment
    has_many :subscriptions, :class => TopicSubscription
    has :vote, :class => TopicVote
    has_many Tag, :extend => Tag::Update

    def votes(opts = {})
      return @votes if @votes && !opts[:reload]

      association = ZendeskAPI::Association.new(:class => TopicVote, :parent => self, :path => 'votes')
      @votes = ZendeskAPI::Collection.new(@client, TopicVote, opts.merge(:association => association))
    end
  end

  class Activity < Resource
    has User
    has :actor, :class => User
  end

  class Setting < DataResource
    attr_reader :on

    def initialize(client, attributes = {})
      # Try and find the root key
      @on = (attributes.keys.map(&:to_s) - %w{association options}).first

      # Make what's inside that key the root attributes
      attributes.merge!(attributes.delete(@on))

      super
    end
  end

  class SatisfactionRating < ReadResource
    has :assignee, :class => User
    has :requester, :class => User
    has Ticket
    has Group
  end

  class Search
    class Result < Data; end

    # Creates a search collection
    def self.search(client, options = {})
      unless (%w{query external_id} & options.keys.map(&:to_s)).any?
        warn "you have not specified a query for this search"
      end

      ZendeskAPI::Collection.new(client, self, options)
    end

    # Quack like a Resource
    # Creates the correct resource class from the result_type passed in
    def self.new(client, attributes)
      result_type = attributes["result_type"]

      if result_type
        result_type = ZendeskAPI::Helpers.modulize_string(result_type)
        klass = ZendeskAPI.const_get(result_type) rescue nil
      end

      (klass || Result).new(client, attributes)
    end

    class << self
      def resource_name
        "search"
      end

      alias :resource_path :resource_name

      def model_key
        "results"
      end
    end
  end

  class Request < Resource
    class Comment < ReadResource
      has_many Attachment, :inline => true
      has :author, :class => User
    end

    has_many Comment

    has Organization
    has :requester, :class => User
  end

  class TicketField < Resource; end

  class TicketMetric < DataResource
    extend Read
  end

  class Ticket < Resource
    class Audit < DataResource
      # need this to support SideLoading
      has :author, :class => User
    end

    class Comment < Data
      include Save

      has_many :uploads, :class => Attachment, :inline => true
      has :author, :class => User

      def save
        save_associations
        true
      end

      alias :save! :save
    end

    has :requester, :class => User, :inline => :create
    has :submitter, :class => User
    has :assignee, :class => User
    has_many :collaborators, :class => User
    has_many Audit
    has :metrics, :class => TicketMetric
    has Group
    has :forum_topic, :class => Topic
    has Organization

    has :comment, :class => Comment, :inline => true
    has :last_comment, :class => Comment, :inline => true
    has_many :last_comments, :class => Comment, :inline => true

    has_many Tag, :extend => Tag::Update

    # Gets a incremental export of tickets from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {Ticket}
    def self.incremental_export(client, start_time)
      ZendeskAPI::Collection.new(client, self, :path => "exports/tickets?start_time=#{start_time.to_i}")
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

    # Recovers this suspended ticket to an actual ticket
    put :recover
  end

  class ViewRow < DataResource
    has Ticket

    # @internal Optional columns

    has Group
    has :assignee, :class => User
    has :requester, :class => User
    has :submitter, :class => User
    has Organization

    def self.model_key
      "rows"
    end
  end

  class RuleExecution < Data
    has_many :custom_fields, :class => TicketField
  end

  class ViewCount < DataResource; end

  class Rule < Resource
    private

    def attributes_for_save
      to_save = [:conditions, :actions, :output].inject({}) {|h,k| h.merge(k => send(k))}
      { self.class.singular_resource_name.to_sym => attributes.changes.merge(to_save) }
    end
  end

  class View < Rule
    has_many :tickets, :class => Ticket
    has_many :feed, :class => Ticket, :path => "feed"

    has_many :rows, :class => ViewRow, :path => "execute"
    has :execution, :class => RuleExecution
    has ViewCount, :path => "count"

    def self.preview(client, options = {})
      Collection.new(client, ViewRow, options.merge(:path => "views/preview", :verb => :post))
    end
  end

  class Trigger < Rule
    has :execution, :class => RuleExecution
  end

  class Automation < Rule
    has :execution, :class => RuleExecution
  end

  class Macro < Rule
    has :execution, :class => RuleExecution

    # Returns the update to a ticket that happens when a macro will be applied.
    # @param [Ticket] ticket Optional {Ticket} to apply this macro to.
    # @raise [Faraday::Error::ClientError] Raised for any non-200 response.
    def apply!(ticket = nil)
      path = "#{self.path}/apply"

      if ticket
        path = "#{ticket.path}/#{path}"
      end

      response = @client.connection.get(path)
      Hashie::Mash.new(response.body.fetch("result", {}))
    end

    # Returns the update to a ticket that happens when a macro will be applied.
    # @param [Ticket] ticket Optional {Ticket} to apply this macro to
    def apply(ticket = nil)
      apply!(ticket)
    rescue Faraday::Error::ClientError => e
      Hashie::Mash.new
    end
  end

  class GroupMembership < Resource
    has User
    has Group
  end

  class User < Resource
    class TopicComment < TopicComment
      extend Read
    end

    class Identity < Resource
      # Makes this identity the primary one bumping all other identities down one
      put :make_primary

      # Verifies this identity
      put :verify

      # Requests verification for this identity
      put :request_verification
    end

    def initialize(*)
      super

      # Needed for proper Role sideloading
      self.role_id = role.name if key?(:role)
    end

    has Organization

    has CustomRole, :inline => true, :include => :roles
    has Role, :inline => true, :include_key => :name
    has Ability, :inline => true

    has_many Identity

    has_many Request
    has_many :requested_tickets, :class => Ticket, :path => 'tickets/requested'
    has_many :ccd_tickets, :class => Ticket, :path => 'tickets/ccd'

    has_many Group
    has_many GroupMembership
    has_many Topic

    has_many ForumSubscription
    has_many TopicSubscription
    has_many :topic_comments, :class => TopicComment
    has_many :topic_votes, :class => Topic::TopicVote
  end

  class UserField < Resource; end
  class OrganizationField < Resource; end

  class OauthClient < Resource
    namespace "oauth"

    def self.singular_resource_name
      "client"
    end
  end

  class OauthToken < ReadResource
    include Destroy
    namespace "oauth"

    def self.singular_resource_name
      "token"
    end
  end

  class Target < Resource; end

  module Voice
    class PhoneNumber < Resource
      namespace "channels/voice"
    end
  end
end

module ZendeskAPI
  # @internal The following are redefined later, but needed by some circular resources (e.g. Ticket -> User, User -> Ticket)

  class Ticket < Resource; end
  class User < Resource; end
  class UserRelated < DataResource; end
  class Category < Resource; end
  class OrganizationSubscription < ReadResource; end
  class CustomStatus < Resource; end

  # @internal Begin actual Resource definitions

  class RecipientAddress < Resource; end

  class Locale < ReadResource; end

  class CustomRole < DataResource; end

  class WorkItem < Resource; end

  class Channel < Resource
    def work_items
      @work_items ||= attributes.fetch('relationships', {}).fetch('work_items', {}).fetch('data', []).map do |work_item_attributes|
        WorkItem.new(@client, work_item_attributes)
      end
    end
  end

  # client.agent_availabilities.fetch
  # client.agent_availabilities.find 20401208368
  # both return consistently - ZendeskAPI::AgentAvailability
  class AgentAvailability < DataResource
    def self.model_key
      "data"
    end

    def initialize(client, attributes = {})
      nested_attributes = attributes.delete('attributes')
      super(client, attributes.merge(nested_attributes))
    end

    def self.find(client, id)
      attributes = client.connection.get("#{resource_path}/#{id}").body.fetch(model_key, {})
      new(client, attributes)
    end

    #  Examples:
    #  ZendeskAPI::AgentAvailability.search(client, { channel_status: 'support:online' })
    #  ZendeskAPI::AgentAvailability.search(client, { agent_status_id: 1 })
    #  Just pass a hash that includes the key and value you want to search for, it gets turned into a query string
    #  on the format of filter[key]=value
    #  Returns a collection of AgentAvailability objects
    def self.search(client, args_hash)
      query_string = args_hash.map { |k, v| "filter[#{k}]=#{v}" }.join("&")
      client.connection.get("#{resource_path}?#{query_string}").body.fetch(model_key, []).map do |attributes|
        new(client, attributes)
      end
    end

    def channels
      @channels ||= begin
        channel_attributes_array = @client.connection.get(attributes['links']['self']).body.fetch('included')
        channel_attributes_array.map do |channel_attributes|
          nested_attributes = channel_attributes.delete('attributes')
          Channel.new(@client, channel_attributes.merge(nested_attributes))
        end
      end
    end
  end

  class Role < DataResource
    def to_param
      name
    end
  end

  class Topic < Resource
    class << self
      def cbp_path_regexes
        [%r{^community/topics$}]
      end

      def resource_path
        "community/topics"
      end
    end
  end

  class Bookmark < Resource; end
  class Ability < DataResource; end
  class Group < Resource; end
  class SharingAgreement < ReadResource; end
  class JobStatus < ReadResource; end

  class Session < ReadResource
    include Destroy
  end

  class Tag < DataResource
    include Update
    include Destroy

    alias :name :id
    alias :to_param :id

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

        @client.connection.post(path) do |req|
          req.body = { :tags => @resources.reject(&:destroyed?).map(&:id) }
        end

        true
      rescue Faraday::ClientError => e
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

    def self.cbp_path_regexes
      [/^tags$/]
    end
  end

  class Attachment < ReadResource
    def initialize(client, attributes = {})
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

    def id
      token
    end

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

  class OrganizationRelated < DataResource; end

  class OrganizationMembership < ReadResource
    extend CreateOrUpdate
  end

  class Organization < Resource
    extend CreateMany
    extend CreateOrUpdate
    extend DestroyMany

    has Ability, :inline => true
    has Group
    has :related, :class => OrganizationRelated

    has_many Ticket
    has_many User
    has_many Tag, :extend => Tag::Update, :inline => :create
    has_many OrganizationMembership
    has_many :subscriptions, class: OrganizationSubscription

    # Gets a incremental export of organizations from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {Organization}
    def self.incremental_export(client, start_time)
      ZendeskAPI::Collection.new(client, self, :path => "incremental/organizations?start_time=#{start_time.to_i}")
    end

    def self.cbp_path_regexes
      [/^organizations$/]
    end
  end

  class Brand < Resource
    def self.cbp_path_regexes
      [/^brands$/]
    end

    def destroy!
      self.active = false
      save!

      super
    end
  end

  class OrganizationMembership < ReadResource
    include Create
    include Destroy

    extend CreateMany
    extend DestroyMany

    has User
    has Organization
  end

  class OrganizationSubscription < ReadResource
    include Create
    include Destroy

    has User
    has Organization

    def self.cbp_path_regexes
      [%r{^organizations/\d+/subscriptions$}]
    end
  end

  class Category < Resource
    class << self
      def resource_path
        "help_center/categories"
      end
    end

    class Section < Resource
    end

    class Translation < Resource; end

    has_many Section
    has_many Translation
  end

  class Section < ReadResource
    class << self
      def resource_path
        "help_center/sections"
      end
    end

    has Category

    class Vote < Resource; end
    class Translation < Resource; end

    class Article < Resource
      has_many Vote
      has_many Translation
    end

    has_many Translation
    has_many Article
  end

  class Article < ReadResource
    class << self
      def resource_path
        "help_center/articles"
      end
    end

    class Vote < Resource; end
    has_many Vote
    class Translation < Resource; end
    has_many Translation
    class Label < DataResource
      include Read
      include Create
      include Destroy

      def destroy!
        super do |req|
          req.path = path
        end
      end
    end
    has_many Label
  end

  class TopicSubscription < Resource
    class << self
      def model_key
        "subscriptions"
      end
    end

    has Topic
    has User

    def path(options = {})
      super(options.merge(:with_parent => true))
    end
  end

  class Topic < Resource
    has_many :subscriptions, class: TopicSubscription, inline: true
    has_many Tag, extend: Tag::Update, inline: :create
    has_many Attachment
    has_many :uploads, class: Attachment, inline: true
  end

  class Activity < Resource
    has User
    has :actor, :class => User

    def self.cbp_path_regexes
      [/^activities$/]
    end
  end

  class Setting < UpdateResource
    attr_reader :on

    def initialize(client, attributes = {})
      # Try and find the root key
      @on = (attributes.keys.map(&:to_s) - %w{association options}).first

      # Make what's inside that key the root attributes
      attributes.merge!(attributes.delete(@on))

      super
    end

    def new_record?
      false
    end

    def path(options = {})
      super(options.merge(:with_parent => true))
    end

    def attributes_for_save
      { self.class.resource_name => { @on => attributes.changes } }
    end
  end

  class SatisfactionRating < ReadResource
    has :assignee, :class => User
    has :requester, :class => User
    has Ticket
    has Group
  end

  class Interval < Resource; end

  class Schedule < Resource
    has_many Interval

    class << self
      def resource_path
        "business_hours/schedules"
      end
    end
  end

  class Request < Resource
    class Comment < DataResource
      include Save

      has_many :uploads, class: Attachment, inline: true
      has :author, :class => User

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

    has Comment, :inline => true
    has_many Comment

    has Organization
    has Group
    has :requester, :class => User
  end

  class AnonymousRequest < CreateResource
    def self.singular_resource_name
      'request'
    end

    namespace 'portal'
  end

  class TicketField < Resource
    def self.cbp_path_regexes
      [/^ticket_fields$/]
    end
  end

  class TicketMetric < DataResource
    include Read

    def self.cbp_path_regexes
      [/^ticket_metrics$/]
    end
  end

  class TicketRelated < DataResource; end

  class TicketEvent < DataResource
    class Event < Data; end

    has_many :child_events, class: Event
    has Ticket
    has :updater, :class => User

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

    def self.cbp_path_regexes
      [/^tickets$/, %r{organizations/\d+/tickets}, %r{users/\d+/tickets/requested}]
    end

    # Unlike other attributes, "comment" is not a property of the ticket,
    # but is used as a "comment on save", so it should be kept unchanged,
    # See https://github.com/zendesk/zendesk_api_client_rb/issues/321
    def attribute_changes
      attributes.changes.merge("comment" => attributes["comment"])
    end

    class Audit < DataResource
      class Event < Data
        has :author, :class => User
      end

      put :trust

      # need this to support SideLoading
      has :author, :class => User

      has_many Event

      def self.cbp_path_regexes
        [%r{^tickets/\d+/audits$}]
      end
    end

    class Comment < DataResource
      include Save

      has_many :uploads, class: Attachment, inline: true
      has :author, class: User

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
      class << self
        alias :resource_name :singular_resource_name
      end
    end

    put :mark_as_spam
    post :merge

    has :requester, :class => User, :inline => :create
    has :submitter, :class => User
    has :assignee, :class => User

    has_many :collaborators, class: User, inline: true, extend: Module.new do
      def to_param
        map(&:id)
      end
    end

    has_many Audit
    has :metrics, class: TicketMetric
    has Group
    has Organization
    has Brand
    has :related, class: TicketRelated

    has Comment, inline: true
    has_many Comment

    has :last_comment, class: Comment, inline: true
    has_many :last_comments, class: Comment, inline: true

    has_many Tag, extend: Tag::Update, inline: :create

    has_many :incidents, class: Ticket

    # Gets a incremental export of tickets from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {Ticket}
    def self.incremental_export(client, start_time)
      ZendeskAPI::Collection.new(client, self, path: "incremental/tickets?start_time=#{start_time.to_i}")
    end

    # Imports a ticket through the imports/tickets endpoint using save!
    # @param [Client] client The {Client} object to be used
    # @param [Hash] attributes The attributes to create.
    # @return [Ticket] Created object or nil
    def self.import!(client, attributes)
      new(client, attributes).tap do |ticket|
        ticket.save!(path: "imports/tickets")
      end
    end

    # Imports a ticket through the imports/tickets endpoint
    # @param [Client] client The {Client} object to be used
    # @param [Hash] attributes The attributes to create.
    # @return [Ticket] Created object or nil
    def self.import(client, attributes)
      ticket = new(client, attributes)
      return unless ticket.save(path: "imports/tickets")
      ticket
    end
  end

  class SuspendedTicket < ReadResource
    include Destroy

    # Recovers this suspended ticket to an actual ticket
    put :recover

    def self.cbp_path_regexes
      [/^suspended_tickets$/]
    end
  end

  class TargetFailure < ReadResource
    def target
      @client.targets.to_a.find do |target|
        target.title == self.target_name
      end
    end
  end

  class DeletedTicket < ReadResource
    include Destroy
    extend DestroyMany

    # Restores this previously deleted ticket to an actual ticket
    put :restore
    put :restore_many

    def self.cbp_path_regexes
      [/^deleted_tickets$/]
    end
  end

  class UserViewRow < DataResource
    has User
    def self.model_key
      "rows"
    end
  end

  class ViewRow < DataResource
    has Ticket

    # @internal Optional columns

    has Group
    has :assignee, class: User
    has :requester, class: User
    has :submitter, class: User
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
      to_save = [:conditions, :actions, :output].inject({}) { |h, k| h.merge(k => send(k)) }
      { self.class.singular_resource_name.to_sym => attributes.changes.merge(to_save) }
    end
  end

  class TriggerCategory < Resource; end

  module Conditions
    def all_conditions=(all_conditions)
      self.conditions ||= {}
      self.conditions[:all] = all_conditions
    end

    def any_conditions=(any_conditions)
      self.conditions ||= {}
      self.conditions[:any] = any_conditions
    end

    def add_all_condition(field, operator, value)
      self.conditions ||= {}
      self.conditions[:all] ||= []
      self.conditions[:all] << { :field => field, :operator => operator, :value => value }
    end

    def add_any_condition(field, operator, value)
      self.conditions ||= {}
      self.conditions[:any] ||= []
      self.conditions[:any] << { :field => field, :operator => operator, :value => value }
    end
  end

  module Actions
    def add_action(field, value)
      self.actions ||= []
      self.actions << { :field => field, :value => value }
    end
  end

  class View < Rule
    include Conditions

    has_many :tickets, :class => Ticket
    has_many :feed, :class => Ticket, :path => "feed"

    has_many :rows, :class => ViewRow, :path => "execute"
    has :execution, :class => RuleExecution
    has ViewCount, :path => "count"

    def add_column(column)
      columns = execution.columns.map(&:id)
      columns << column
      self.columns = columns
    end

    def columns=(columns)
      self.output ||= {}
      self.output[:columns] = columns
    end

    def self.preview(client, options = {})
      Collection.new(client, ViewRow, options.merge(:path => "views/preview", :verb => :post))
    end

    def self.cbp_path_regexes
      [/^views$/]
    end
  end

  class Trigger < Rule
    include Conditions
    include Actions

    has :execution, :class => RuleExecution

    def self.cbp_path_regexes
      [/^triggers$/, %r{^triggers/active$}]
    end
  end

  class Automation < Rule
    include Conditions
    include Actions

    has :execution, :class => RuleExecution

    def self.cbp_path_regexes
      [/^automations$/]
    end
  end

  class Macro < Rule
    include Actions

    has :execution, :class => RuleExecution

    def self.cbp_path_regexes
      [/^macros$/]
    end

    # Returns the update to a ticket that happens when a macro will be applied.
    # @param [Ticket] ticket Optional {Ticket} to apply this macro to.
    # @raise [Faraday::ClientError] Raised for any non-200 response.
    def apply!(ticket = nil)
      path = "#{self.path}/apply"

      if ticket
        path = "#{ticket.path}/#{path}"
      end

      response = @client.connection.get(path)
      SilentMash.new(response.body.fetch("result", {}))
    end

    # Returns the update to a ticket that happens when a macro will be applied.
    # @param [Ticket] ticket Optional {Ticket} to apply this macro to
    def apply(ticket = nil)
      apply!(ticket)
    rescue Faraday::ClientError
      SilentMash.new
    end
  end

  class UserView < Rule
    def self.preview(client, options = {})
      Collection.new(client, UserViewRow, options.merge!(:path => "user_views/preview", :verb => :post))
    end
  end

  class GroupMembership < Resource
    extend CreateMany
    extend DestroyMany

    has User
    has Group

    def self.cbp_path_regexes
      [%r{^groups/\d+/memberships$}]
    end
  end

  class Group < Resource
    has_many :memberships, class: GroupMembership, path: "memberships"

    def self.cbp_path_regexes
      [/^groups$/, %r{^groups/assignable$}]
    end
  end

  class User < Resource
    extend CreateMany
    extend UpdateMany
    extend CreateOrUpdate
    extend CreateOrUpdateMany
    extend DestroyMany

    class GroupMembership < Resource
      put :make_default
    end

    class Identity < Resource
      # Makes this identity the primary one bumping all other identities down one
      put :make_primary

      # Verifies this identity
      put :verify

      # Requests verification for this identity
      put :request_verification
    end

    def self.cbp_path_regexes
      [/^users$/, %r{^organizations/\d+/users$}]
    end

    any :password

    # Set a user's password
    def set_password(opts = {})
      password(opts.merge(:verb => :post))
    end

    # Change a user's password
    def change_password(opts = {})
      password(opts.merge(:verb => :put))
    end

    # Set a user's password
    def set_password!(opts = {})
      password!(opts.merge(:verb => :post))
    end

    # Change a user's password
    def change_password!(opts = {})
      password!(opts.merge(:verb => :put))
    end

    # Gets a incremental export of users from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {User}
    def self.incremental_export(client, start_time)
      ZendeskAPI::Collection.new(client, self, :path => "incremental/users?start_time=#{start_time.to_i}")
    end

    has Organization

    class Session < Resource
    end

    class CurrentSession < SingularResource
      class << self
        def singular_resource_name
          'session'
        end

        alias :resource_name :singular_resource_name
      end
    end

    has_many Session

    def current_session
      ZendeskAPI::User::CurrentSession.find(@client, :user_id => 'me')
    end

    delete :logout

    def clear_sessions!
      @client.connection.delete("#{path}/sessions")
    end

    def clear_sessions
      clear_sessions!
    rescue ZendeskAPI::Error::ClientError
      false
    end

    put :merge

    has CustomRole, :inline => true, :include => :roles
    has Role, :inline => true, :include_key => :name
    has Ability, :inline => true
    has :related, :class => UserRelated

    has_many Identity

    has_many Request
    has_many :requested_tickets, :class => Ticket, :path => 'tickets/requested'
    has_many :assigned_tickets, :class => Ticket, :path => 'tickets/assigned'
    has_many :ccd_tickets, :class => Ticket, :path => 'tickets/ccd'

    has_many Group
    has_many GroupMembership
    has_many OrganizationMembership
    has_many OrganizationSubscription

    has_many Setting
    has_many Tag, :extend => Tag::Update, :inline => :create

    def attributes_for_save
      # Don't send role_id, it's necessary
      # for side-loading, but causes problems on save
      # see #initialize
      attrs = attributes.changes.delete_if do |k, _|
        k == "role_id"
      end

      { self.class.singular_resource_name => attrs }
    end

    def handle_response(*)
      super

      # Needed for proper Role sideloading
      self.role_id = role.name if key?(:role)
    end
  end

  class DeletedUser < ReadResource
    include Destroy
  end

  class UserField < Resource; end
  class OrganizationField < Resource; end

  class OauthClient < Resource
    namespace "oauth"

    def self.singular_resource_name
      "client"
    end

    def self.cbp_path_regexes
      [%r{^oauth/clients$}]
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

  class Invocation < Resource; end

  class Webhook < Resource
    has_many Invocation
  end

  module Voice
    include DataNamespace

    class PhoneNumber < Resource
      namespace "channels/voice"
    end

    class Address < Resource
      namespace "channels/voice"
    end

    class Greeting < Resource
      namespace "channels/voice"
    end

    class GreetingCategory < Resource
      namespace "channels/voice"
    end

    class Ticket < CreateResource
      namespace "channels/voice"
    end

    class Agent < ReadResource
      namespace "channels/voice"

      class Ticket < CreateResource
        def new_record?
          true
        end

        def self.display!(client, options)
          new(client, options).tap do |resource|
            resource.save!(path: "#{resource.path}/display")
          end
        end
      end

      has_many Ticket
    end
  end

  class TicketForm < Resource
    # TODO
    # post :clone
  end

  class AppInstallation < Resource
    namespace "apps"

    def self.singular_resource_name
      "installation"
    end

    # Don't nest attributes
    def attributes_for_save
      attributes.changes
    end

    def handle_response(response)
      @attributes.replace(response.body) if response.body
    end
  end

  class AppNotification < CreateResource
    class << self
      def resource_path
        "apps/notify"
      end
    end

    # Don't nest attributes
    def attributes_for_save
      attributes.changes
    end

    def handle_response(response)
      @attributes.replace(response.body) if response.body.is_a?(Hash)
    end
  end

  class App < Resource
    def initialize(client, attributes = {})
      attributes[:upload_id] ||= nil

      super
    end

    def self.create!(client, attributes = {}, &)
      if file_path = attributes.delete(:upload)
        attributes[:upload_id] = client.apps.uploads.create!(:file => file_path).id
      end

      super
    end

    class Plan < Resource
    end

    class Upload < Data
      class << self
        def resource_path
          "uploads"
        end
      end

      include Create

      def initialize(client, attributes)
        attributes[:file] ||= attributes.delete(:id)

        super
      end

      # Not nested under :upload, just returns :id
      def save!(*)
        super.tap do
          attributes.id = @response.body["id"]
        end
      end

      # Always save
      def changed?
        true
      end

      # Don't nest attributes
      def attributes_for_save
        attributes
      end
    end

    def self.uploads(client, ...)
      ZendeskAPI::Collection.new(client, Upload, ...)
    end

    def self.installations(client, ...)
      ZendeskAPI::Collection.new(client, AppInstallation, ...)
    end

    has Upload, :path => "uploads"
    has_many Plan

    # Don't nest attributes
    def attributes_for_save
      attributes.changes
    end

    def handle_response(response)
      @attributes.replace(response.body) if response.body
    end
  end

  module DynamicContent
    include DataNamespace

    class Item < ZendeskAPI::Resource
      namespace 'dynamic_content'

      class Variant < ZendeskAPI::Resource
      end

      has_many Variant
    end
  end

  class PushNotificationDevice < DataResource
    def self.destroy_many(client, tokens)
      ZendeskAPI::Collection.new(
        client, self, "push_notification_devices" => tokens,
        :path => "push_notification_devices/destroy_many",
        :verb => :post
      )
    end
  end
end

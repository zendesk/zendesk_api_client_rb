class ZendeskAPI::FormatError < ArgumentError; end

module Console
  def self.included(klass)
    klass.instance_eval { alias :orig_log_error :log_error }
  end

  def /(id)
    if id == ZendeskAPI::Console::ZD_DIRUP
      if @collection_path.length == 1
        @client
      else
        @collection_path.shift
        self
      end
    elsif id.is_a?(Fixnum)
      if loaded?
        detect {|obj| obj.id == id}
      else
        find(:id => id)
      end
    elsif !id.is_a?(ZendeskAPI::Collection)
      send(id)
    end
  end

  def log_error(e, _)
    raise e
  end

  def loaded?
    @resources && @resources.any?
  end

  def to_s
    path
  end

  def format_headers
    @resource_class.format_headers
  end
end

ZendeskAPI::Collection.send(:include, Console)

module Subclasses
  def self.included(klass)
    klass.extend ClassMethods
  end

  GET_SUBCLASSES = lambda do |ary|
    ary.map! do |klass|
      if klass.name =~ /Resource$/
        GET_SUBCLASSES.call(klass.subclasses)
      else
        klass
      end
    end

    ary.tap(&:flatten!)
  end

  def to_s
    "/"
  end

  def to_a
    self.class.resources
  end

  def format_headers
    ["resource name"]
  end

  module ClassMethods
    def resources
      @resources ||= begin
        subclasses = GET_SUBCLASSES.call(ZendeskAPI::Data.subclasses)
        subclasses.delete_if do |resource|
          resource.name =~ /ZendeskAPI(::.*){2,}/
        end
        subclasses.sort_by(&:resource_name)
      end
    end
  end
end

ZendeskAPI::Client.send(:include, Subclasses)

module Path
  def /(method)
    if method == ZendeskAPI::Console::ZD_DIRUP
      if association.options.parent
        association.options.parent
      elsif (res = @client.send(self.class.resource_name)).loaded?
        res
      else
        ZendeskAPI::Collection.new(@client, self.class)
      end
    else
      send(method)
    end
  end
end

module Format
  def self.extended(klass)
    class << klass
      attr_accessor :format_headers
    end
  end

  def format(client = nil, &block)
    if block_given?
      class_eval do
        define_method :format do
          instance_eval &block
        end
      end
    elsif client && client.send(resource_name).loaded?
      ["@#{resource_name}"]
    else
      [resource_name]
    end
  end
end

ZendeskAPI::Data.send(:include, Path)
ZendeskAPI::Data.extend Format

ZendeskAPI::DataResource.instance_eval do
  format_headers = %w{id created_at}

  format do
    if self.format_headers
      self.format_headers.map {|attr| send(attr.to_s.downcase)}
    else
      raise ZendeskAPI::FormatError.new("#{self.class.name} hasn't defined an ouput format")
    end
  end
end

module ZendeskAPI
  ForumSubscription.format_headers = %w{id forum_id user_id created_at}
  GroupMembership.format_headers = %w{id group_id user_id created_at}
  TopicSubscription.format_headers = %w{id topic_id user_id created_at}
  Locale.format_headers = %w{Id Locale Name}
  TicketField.format_headers = %w{Id Type Title Description}
  Macro.format_headers = %w{Id Title}

  Forum.format_headers = %w{Id Name Description Created Updated}
  Forum.format do
    [id, name, description, created_at, updated_at]
  end

  Category.format_headers = %w{Id Name Description Position Created Updated}
  Category.format do
    [id, name, description, position, created_at, updated_at]
  end

  Topic.format_headers = %w{Id Title Type}
  Topic.format do
    [id, title, topic_type]
  end

  # Topic::*, MobileDevice, TicketMetric, SuspendedTicket, customRole, CrmData...

  Activity.format_headers = %w{Id Title User Actor Ticket}
  Activity.format do
    [id, title, user.name, actor.name, target.ticket.subject]
  end

  SatisfactionRating.format_headers = %w{Id Ticket Score Comment}
  SatisfactionRating.format do
    [id, ticket_id, score, comment]
  end

  Bookmark.format_headers = %w{Id Ticket Created}
  Bookmark.format do
    [id, ticket.id, created_at]
  end

  User.format_headers = %w{Id Name Email Created Updated}
  User.format do
    [id, name, email, created_at, updated_at]
  end

  Ticket.format_headers = %w{Id Type Subject Description Status Created Updated}
  Ticket.format do
    [id, type, subject, description, status, created_at, updated_at]
  end

  Organization.format_headers = %w{Id Name Created Updated}
  Organization.format do
    [id, name, created_at, updated_at]
  end

  View.format_headers = %w{Id Title Created Updated}
  View.format do
    [id, title, created_at, updated_at]
  end
end

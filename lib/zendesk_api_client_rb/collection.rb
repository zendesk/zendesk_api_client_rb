require 'facets/string/camelcase'
require 'english/inflect'

module Zendesk
  private
  
  # Allows using has and has_many without having class defined yet
  def self.get_class(resource)
    begin
      const_get(resource)
    rescue NameError
      const_set(resource, Class.new(Resource))
    end
  end

  public

  class Resource 
    class << self
      def has(resource, klass = nil)
        klass = Zendesk.get_class(resource.to_s.upper_camelcase) unless klass

        define_method resource do
          if id = @attributes["#{resource}_id"]
            klass.find(@client, id)
          elsif (res = @attributes[resource.to_s]) && res.is_a?(Hash)
            klass.new(@client, res)
          end
        end
      end

      def has_many(resource, klass = nil)
        klass = Zendesk.get_class(resource.to_s.singular.upper_camelcase) unless klass

        define_method resource do
          singular = resource.to_s.singular
          
          if (ids = @attributes["#{singular}_ids"]) && ids.any?
            collection = ids.map do |id| 
              klass.find(@client, id)
            end.compact
            
            plural_resource = klass.to_s.downcase.split("::").last.plural
            Zendesk::Collection.new(@client, plural_resource, { plural_resource => collection })
          elsif (res = @attributes[resource.to_s]) && res.any?
            plural_resource = klass.to_s.downcase.split("::").last.plural
            Zendesk::Collection.new(@client, plural_resource, { plural_resource => res })
          else
            # Here is where we would request things
            # like if topic.comments
            # w/class of TopicComment
            []
          end
        end
      end

      def find(client, id)
        klass = to_s.downcase.gsub(/zendesk::/, '')
        response = client.connection.get("#{klass}s/#{id}.#{client.config.format}")

        if response.status == 200
          new(client, response.body[klass])
        else
          # log error?
          nil
        end
      end
    end

    attr_reader :attributes
    def initialize(client, attributes)
      @client = client
      @attributes = attributes
    end

    def method_missing(name, *args, &block)
      if attributes.include?(name.to_s)
        attributes[name.to_s]
      else
        super
      end
    end

    def id
      attributes["id"]
    end
  end


  class User < Resource
    has :organization
    has :custom_role
  end

  class Organization < Resource
    has :group
  end

  class Topic < Resource
  end

  class Ticket < Resource
    has :submitter, User
    has :assignee, User
    has :recipient, User
    has_many :collaborators, User
    has :group
    has :forum_topic, Topic
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
    has :actor, User
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
  end

  class SatisfactionRating < Resource
    has :assignee, User
    has :requester, User
    has :ticket
    has :group
  end

  class Upload < Resource
  end

  class Category < Resource
  end

  class Forum < Resource
    has :category
    has :organization
    has :locale
  end

  class Attachment < Resource
  end

  class TopicComment < Resource
    has :topic
    has :user
    has_many :attachments
  end

  class TopicSubscription < Resource
    has :topic
    has :user
  end

  class ForumSubscription < Resource
    has :forum
    has :user
  end
end

module Zendesk
  class Collection < Array
    attr_reader :count
    def initialize(client, resource, body)
      @client, @resource = client, resource

      singular_resource = Zendesk.const_get(resource.singular.upper_camelcase)
      @resources = body[resource].map do |res|
        singular_resource.new(client, res)
      end

      super(@resources)

      @next_page, @prev_page = body["next_page"], body["previous_page"]
      @count = (body["count"] || size).to_i
    end

    def next
      if @next_page
        Collection.new(@client, @resource, @client.connection.get(@next_page).body)
      else
        []
      end
    end

    def prev
      if @prev_page
        Collection.new(@client, @resource, @client.connection.get(@prev_page).body)
      else
        []
      end
    end
  end
end

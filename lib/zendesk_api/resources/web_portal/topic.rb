module ZendeskAPI
  class TopicSubscription < Resource
    has :topic, class: 'Topic'
    has :user, class: 'User'
  end

  class TopicComment < Data
    has :topic, class: 'Topic'
    has :user, class: 'User'
    has_many :attachments, class: 'Attachment'
  end

  class Topic < Resource
    class TopicComment < TopicComment
      include Read
      include Create
      include Update
      include Destroy

      has_many :uploads, class: 'Attachment', inline: true

      def self.import!(client, attributes)
        new(client, attributes).tap do |comment|
          comment.save!(:path => 'import/' + comment.path)
        end
      end

      def self.import(client, attributes)
        comment = new(client, attributes)
        return unless comment.save(:path => 'import/' + comment.path)
        comment
      end
    end

    class TopicVote < SingularResource
      has :topic, class: 'Topic'
      has :user, class: 'User'

      private

      def attributes_for_save
        attributes.changes
      end
    end

    has :forum, class: 'Forum'
    has_many :comments, class: 'TopicComment'
    has_many :subscriptions, class: 'TopicSubscription'
    has :vote, class: 'TopicVote'
    has_many :tags, class: 'Tag', extend: 'Tag::Update', inline: :create
    has_many :attachments, class: 'Attachment'
    has_many :uploads, class: 'Attachment', inline: true

    def votes(opts = {})
      return @votes if @votes && !opts[:reload]

      association = ZendeskAPI::Association.new(:class => TopicVote, :parent => self, :path => 'votes')
      @votes = ZendeskAPI::Collection.new(@client, TopicVote, opts.merge(:association => association))
    end

    def self.import!(client, attributes)
      new(client, attributes).tap do |topic|
        topic.save!(:path => "import/topics")
      end
    end

    def self.import(client, attributes)
      topic = new(client, attributes)
      return unless topic.save(:path => "import/topics")
      topic
    end
  end
end

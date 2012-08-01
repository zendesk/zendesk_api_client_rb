module ZendeskAPI
  class Activity < Resource
    has :user
    has :actor, :class => :user
  end

  class Setting < DataResource
    attr_reader :on

    def initialize(client, attributes = {})
      @on = attributes.first
      super(client, attributes[1])
    end
  end

  class MobileDevice < Resource
    put :clear_badge
  end

  class SatisfactionRating < ReadResource
    has :assignee, :class => :user 
    has :requester, :class => :user
    has :ticket
    has :group
  end

  class Attachment < Data
    def initialize(client, attributes)
      if attributes.is_a?(Hash)
        super
      else
        super(client, :file => attributes)
      end
    end

    def save
      upload = Upload.create!(@client, :file => file)
      self.token = upload.token
    end

    def to_param
      token
    end
  end

  class Upload < Data
    include Create

    only_send_unnested_params
    has_many :attachments
  end

  class Locale < ReadResource; end
  class Bookmark < Resource; end
  class Macro < DataResource; end

  class Search < DataResource
    def self.resource_name
      "search"
    end

    def self.model_key
      "results"
    end
  end
end

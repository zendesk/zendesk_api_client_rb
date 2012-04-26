module Zendesk
  class Activity < Resource
    has :user
    has :actor, :class => :user
  end

  class Setting < DataResource
    attr_reader :on

    def initialize(client, attributes = {}, path = [])
      @on = attributes.first
      super(client, attributes[1], path)
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

  class Upload < CreateResource; end
  class Attachment < DataResource; end
  class Locale < ReadResource; end
  class Bookmark < Resource; end
  class Macro < DataResource; end
end

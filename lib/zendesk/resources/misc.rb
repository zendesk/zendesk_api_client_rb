module Zendesk
  class Activity < Resource
    has :user
    has :actor, :class => :user
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

  class Upload < Resource; end
  class Attachment < Resource; end
  class Locale < Resource; end
  class Bookmark < Resource; end
  class Macro < Resource; end
end

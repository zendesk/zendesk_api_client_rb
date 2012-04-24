module Zendesk
  class Activity < Resource
    has :user
    has :actor, :class => :user

    allow_parameters :since
  end

  class Setting < DataResource
    attr_reader :on

    def initialize(client, attributes)
      @on = attributes.first
      super(client, attributes[1])
    end
  end

  class MobileDevice < Resource
    put :clear_badge

    allow_parameters :mobile_device => [:device_type, :token, :c2dm_registration_id]
  end

  class SatisfactionRating < ReadResource
    has :assignee, :class => :user 
    has :requester, :class => :user
    has :ticket
    has :group
  end

  class Upload < CreateResource
    allow_parameters :uploaded_data, :token
  end

  class Attachment < DataResource; end
  class Locale < ReadResource; end

  class Bookmark < Resource
    allow_parameters :ticket_id
  end

  class Macro < DataResource
  end
end

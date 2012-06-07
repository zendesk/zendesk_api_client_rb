require 'zendesk_api/resources/forum'

module ZendeskAPI
  class CRMData < DataResource; end
  class CRMDataStatus < DataResource; end
  class CustomRole < DataResource; end

  class GroupMembership < Resource
    has :user
    has :group
  end

  class User < Resource
    class Identity < Resource
      put :make_primary
      put :verify
      put :request_verification
    end

    has :organization
    has :custom_role
    has_many :identities
    has_many :requested_tickets, :class => :ticket, :path => 'tickets/requested'
    has_many :ccd_tickets, :class => :ticket, :path => 'tickets/ccd'

    has_many :groups
    has_many :group_memberships
    has_many :topics

    has_many :forum_subscriptions, :class => "forum/forum_subscription"
    has_many :topic_subscriptions, :class => "topic/topic_subscription"
    has_many :topic_comments, :class => "topic/topic_comment"
    has_many :topic_votes, :class => "topic/vote"

    has :crm_data
    has :crm_data_status, :path => 'crm_data/status'
  end

  class Organization < Resource
    has :group
    has_many :tickets
    has_many :users
  end
end

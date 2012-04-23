module Zendesk
  class User < Resource
    has :organization
    has :custom_role
    has_many :identities
    has_many :requested_tickets, :class => :ticket, :path => 'tickets/requested'
    has_many :cced_tickets, :class => :ticket, :path => 'tickets/ccd'

    %w{groups topics topic_comments topic_votes topic_subscriptions forum_subscriptions}.each do |klass|
      has_many klass.to_sym, :set_path => false
    end

    has :crm_data
    has :crm_data_status, :path => 'crm_data/status'
  end

  class Organization < Resource
    has :group
    has_many :tickets
    has_many :users
  end

  class GroupMembership < Resource
    has :user
    has :group
  end

  class Identity < Resource
    put :make_primary
    put :verify
    put :request_verification
  end

  class CustomRole < Resource; end
  class Group < Resource; end
end

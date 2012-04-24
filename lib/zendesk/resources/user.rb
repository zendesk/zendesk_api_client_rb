module Zendesk
  class CRMData < DataResource; end
  class CRMDataStatus < DataResource; end
  class CustomRole < DataResource; end

  class User < Resource
    has :organization
    has :custom_role
    has_many :identities, :set_path => true
    has_many :requested_tickets, :class => :ticket, :path => 'tickets/requested'
    has_many :cced_tickets, :class => :ticket, :path => 'tickets/ccd'

    %w{groups topics topic_comments topic_votes topic_subscriptions forum_subscriptions}.each do |klass|
      has_many klass.to_sym
    end

    has :crm_data
    has :crm_data_status, :path => 'crm_data/status'

    allow_parameters :user => [:name, :alias, :is_verified, :locale_id, :time_zone, :email, :phone,
      :signature, :details, :notes, :organization_id, :role, :custom_role_id, :is_moderator,
      :ticket_restriction, :is_only_private_comments, :tags, :photo]
  end

  class Organization < Resource
    has :group
    has_many :tickets
    has_many :users

    allow_parameters :organization => [:name, :domain_names, :details, :notes, :group_id, :is_shared_tickets, :is_shared_comments, :tags]
  end

  class GroupMembership < Resource
    has :user
    has :group
    allow_parameters :group_membership => [:user_id, :group_id]
  end

  class Identity < Resource
    put :make_primary
    put :verify
    put :request_verification

    allow_parameters :user_id, :identity => [:twitter, :facebook, :email, :google, :type, :value, :is_verified, :primary]
  end

  class Group < Resource
    allow_parameters :group => [:name, :agents]
  end
end

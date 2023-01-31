module ZendeskAPI
  # https://developer.zendesk.com/api-reference/sales-crm/resources/users/
  class User < Resource
    extend CreateMany
    extend UpdateMany
    extend CreateOrUpdate
    extend CreateOrUpdateMany
    extend DestroyMany

    # https://developer.zendesk.com/api-reference/ticketing/groups/group_memberships/
    class GroupMembership < Resource
      put :make_default
    end

    # https://developer.zendesk.com/api-reference/ticketing/users/user_identities/
    class Identity < Resource
      # Makes this identity the primary one bumping all other identities down one
      put :make_primary

      # Verifies this identity
      put :verify

      # Requests verification for this identity
      put :request_verification
    end

    any :password

    # Set a user's password
    def set_password(opts = {})
      password(opts.merge(:verb => :post))
    end

    # Change a user's password
    def change_password(opts = {})
      password(opts.merge(:verb => :put))
    end

    # Set a user's password
    def set_password!(opts = {})
      password!(opts.merge(:verb => :post))
    end

    # Change a user's password
    def change_password!(opts = {})
      password!(opts.merge(:verb => :put))
    end

    # Gets a incremental export of users from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {User}
    def self.incremental_export(client, start_time)
      ZendeskAPI::Collection.new(client, self, :path => "incremental/users?start_time=#{start_time.to_i}")
    end

    has Organization

    # https://developer.zendesk.com/api-reference/ticketing/account-configuration/sessions/
    class Session < Resource
    end

    # https://developer.zendesk.com/api-reference/ticketing/account-configuration/sessions/#renew-the-current-session
    class CurrentSession < SingularResource
      class << self
        def singular_resource_name
          'session'
        end

        alias resource_name singular_resource_name
      end
    end

    has_many Session

    def current_session
      ZendeskAPI::User::CurrentSession.find(@client, :user_id => 'me')
    end

    delete :logout

    def clear_sessions!
      @client.connection.delete(path + '/sessions')
    end

    def clear_sessions
      clear_sessions!
    rescue ZendeskAPI::Error::ClientError
      false
    end

    put :merge

    has CustomRole, :inline => true, :include => :roles
    has Role, :inline => true, :include_key => :name
    has Ability, :inline => true
    has :related, :class => UserRelated

    has_many Identity

    has_many Request
    has_many :requested_tickets, :class => Ticket, :path => 'tickets/requested'
    has_many :assigned_tickets, :class => Ticket, :path => 'tickets/assigned'
    has_many :ccd_tickets, :class => Ticket, :path => 'tickets/ccd'

    has_many Group
    has_many GroupMembership
    has_many OrganizationMembership
    has_many OrganizationSubscription

    has_many Setting
    has_many Tag, :extend => Tag::Update, :inline => :create

    def attributes_for_save
      # Don't send role_id, it's necessary
      # for side-loading, but causes problems on save
      # see #initialize
      attrs = attributes.changes.delete_if do |k, _|
        k == "role_id"
      end

      { self.class.singular_resource_name => attrs }
    end

    def handle_response(*)
      super

      # Needed for proper Role sideloading
      self.role_id = role.name if key?(:role)
    end
  end
end

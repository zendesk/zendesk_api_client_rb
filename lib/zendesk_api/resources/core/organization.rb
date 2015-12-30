module ZendeskAPI
  class OrganizationField < Resource
    self.resource_name = 'organization_fields'
    self.singular_resource_name = 'organization_field'

    self.collection_paths = ['organization_fields']
    self.resource_paths = ['organization_fields/%{id}']
  end

  class Organization < Resource
    self.resource_name = 'organizations'
    self.singular_resource_name = 'organization'

    self.resource_paths = ['organizations/%{id}']
    self.collection_paths = ['organizations']

    has :ability, class: 'Ability', inline: true
    has :group, class: 'Group'

    has_many :tickets, class: 'Ticket', path: 'organizations/%{id}/tickets'
    has_many :users, class: 'User', path: 'organizations/%{id}/users'
    has_many :tags, class: 'Tag', extend: 'Tag::Update', inline: :create, path: 'organizations/%{id}/tags'
    has_many :memberships, class: 'OrganizationMembership'

    # Gets a incremental export of organizations from the start_time until now.
    # @param [Client] client The {Client} object to be used
    # @param [Integer] start_time The start_time parameter
    # @return [Collection] Collection of {Organization}
    def self.incremental_export(client, start_time)
      ZendeskAPI::Collection.new(client, self, :path => "incremental/organizations?start_time=#{start_time.to_i}")
    end
  end

  class OrganizationMembership < ReadResource
    include Create
    include Destroy

    extend CreateMany
    extend DestroyMany

    self.resource_name = 'organization_memberships'
    self.singular_resource_name = 'organization_membership'

    self.collection_paths = ['organization_memberships']
    self.resource_paths = ['organization_memberships/%{id}']

    has :user, class: 'User'
    has :organization, class: 'Organization'
  end
end

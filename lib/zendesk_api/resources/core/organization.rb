module ZendeskAPI
  class OrganizationField < Resource; end

  class Organization < Resource
    has :ability, class: 'Ability', inline: true
    has :group, class: 'Group'

    has_many :tickets, class: 'Ticket'
    has_many :users, class: 'User'
    has_many :tags, class: 'Tag', extend: 'Tag::Update', inline: :create
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

    has :user, class: 'User'
    has :organization, class: 'Organization'
  end
end

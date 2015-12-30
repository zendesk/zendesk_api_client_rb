module ZendeskAPI
  class Group < Resource
    self.resource_name = 'groups'
    self.singular_resource_name = 'group'

    self.collection_paths = [
      'groups',
      'groups/assignable'
    ]

    self.resource_paths = ['groups/%{id}']
  end

  class GroupMembership < Resource
    extend CreateMany
    extend DestroyMany

    self.resource_name = 'group_memberships'
    self.singular_resource_name = 'group_membership'

    self.collection_paths = ['group_memberships']
    self.resource_paths = ['group_memberships/%{id}']

    has :user, class: 'User'
    has :group, class: 'Group'
  end
end

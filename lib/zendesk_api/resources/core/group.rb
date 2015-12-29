module ZendeskAPI
  class Group < Resource
  end

  class GroupMembership < Resource
    extend CreateMany
    extend DestroyMany

    has :user, class: 'User'
    has :group, class: 'Group'
  end
end

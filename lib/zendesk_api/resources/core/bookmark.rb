module ZendeskAPI
  class Bookmark < Resource
    self.resource_name = 'bookmarks'
    self.singular_resource_name = 'bookmark'
    self.collection_paths = ['bookmarks']
    self.resource_paths = ['bookmarks/%{id}']
  end
end

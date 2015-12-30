module ZendeskAPI
  class Target < Resource
    self.resource_name = 'targets'
    self.singular_resource_name = 'target'

    self.collection_paths = ['targets']
    self.resource_paths = ['targets/%{id}']
  end
end

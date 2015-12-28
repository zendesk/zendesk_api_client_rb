module ZendeskAPI
  class User < Resource
    self.resource_name = 'users'
    self.singular_resource_name = 'user'

    self.resource_paths = [
      'users/%{id}'
    ]

    self.collection_paths = [
      'users'
    ]

    # TODO
  end
end

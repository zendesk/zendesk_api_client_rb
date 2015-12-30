module ZendeskAPI
  class CustomRole < DataResource
    self.resource_name = 'custom_roles'
    self.singular_resource_name = 'custom_role'
    self.collection_paths = ['custom_roles']
  end

  class Role < DataResource
    # TODO?
    def to_param
      name
    end
  end
end

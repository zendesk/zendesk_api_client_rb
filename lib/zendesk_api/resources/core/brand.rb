module ZendeskAPI
  class Brand < Resource
    self.resource_name = 'brands'
    self.singular_resource_name = 'brand'
    self.collection_paths = ['brands']
    self.resource_paths = ['brands/%{id}']

    def destroy!
      self.active = false
      save!

      super
    end
  end
end

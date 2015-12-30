module ZendeskAPI
  class Category < Resource
    self.resource_name = 'categories'
    self.singular_resource_name = 'category'

    self.resource_paths = ['categories/%{id}']
    self.collection_paths = ['categories']

    has_many :forums, class: 'Forum'
  end
end

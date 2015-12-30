module ZendeskAPI
  module DynamicContent
    include DataNamespace

    self.namespace = 'dynamic_content'

    class Variant < ZendeskAPI::Resource
    end

    class Item < ZendeskAPI::Resource
      self.resource_name = 'items'
      self.singular_resource_name = 'item'
      self.resource_paths = ['dynamic_content/items/%{id}']
      self.collection_paths = ['dynamic_content/items']

      namespace 'dynamic_content'

      has_many :variants, class: 'DynamicContent::Variant', path: 'dynamic_content/items/%{id}/variants'
    end
  end
end

module ZendeskAPI
  module DynamicContent
    include DataNamespace

    self.namespace = 'dynamic_content'

    class Item < ZendeskAPI::Resource
      # TODO support moving this out
      # right now the fixtures don't allow it
      class Variant < ZendeskAPI::Resource
        self.resource_name = 'variants'
        self.singular_resource_name = 'variant'
        self.resource_paths = ['dynamic_content/items/%{item_id}/variants/%{id}']
        self.collection_paths = ['dynamic_content/items/%{item_id}/variants']
      end

      self.resource_name = 'items'
      self.singular_resource_name = 'item'
      self.resource_paths = ['dynamic_content/items/%{id}']
      self.collection_paths = ['dynamic_content/items']

      namespace 'dynamic_content'

      has_many :variants, class: 'DynamicContent::Item::Variant', path: 'dynamic_content/items/%{id}/variants'
    end
  end
end

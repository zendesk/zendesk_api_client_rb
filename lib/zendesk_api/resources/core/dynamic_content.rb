module ZendeskAPI
  module DynamicContent
    include DataNamespace

    self.namespace = 'dynamic_content'

    class Variant < ZendeskAPI::Resource
    end

    class Item < ZendeskAPI::Resource
      namespace 'dynamic_content'

      has_many :variants, class: 'DynamicContent::Variant'
    end
  end
end

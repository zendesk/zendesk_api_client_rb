class ZendeskAPI::TestResource < ZendeskAPI::Resource
  self.resource_name = 'test_resources'
  self.singular_resource_name = 'test_resource'

  self.collection_paths = [
    'test_resources',
    'test_resources/recent'
  ]

  self.resource_paths = [
    'test_resources/%{id}'
  ]

  def self.test(client)
    "hi"
  end

  class TestChild < ZendeskAPI::Resource
    self.resource_name = 'test_children'
    self.singular_resource_name = 'test_child'

    self.collection_paths = [
    ]

    self.resource_paths = [
    ]
  end
end

class ZendeskAPI::BulkTestResource < ZendeskAPI::DataResource
  self.resource_name = 'bulk_test_resources'
  self.singular_resource_name = 'bulk_test_resource'

  self.collection_paths = [
    'bulk_test_resources'
  ]

  self.resource_paths = [
  ]

  extend ZendeskAPI::CreateMany
  extend ZendeskAPI::DestroyMany
  extend ZendeskAPI::UpdateMany
end

class ZendeskAPI::NilResource < ZendeskAPI::Data
  self.resource_name = 'nil_resources'
  self.singular_resource_name = 'nil_resource'

  self.collection_paths = [
  ]

  self.resource_paths = [
  ]
end

class ZendeskAPI::NilDataResource < ZendeskAPI::DataResource
  self.resource_name = 'nil_data_resources'
  self.singular_resource_name = 'nil_data_resource'

  self.collection_paths = [
  ]

  self.resource_paths = [
  ]
end

class ZendeskAPI::SingularTestResource < ZendeskAPI::SingularResource
  self.resource_name = 'singular_test_resources'
  self.singular_resource_name = 'singular_test_resource'

  self.collection_paths = [
  ]

  self.resource_paths = [
    'singular_test_resource'
  ]
end

# `client.greetings` should ignore this class, as it's not in the right namespace
class Greeting
end

class ZendeskAPI::TestResource < ZendeskAPI::Resource
  def self.test(client)
    "hi"
  end

  class TestChild < ZendeskAPI::Resource
  end
end

class ZendeskAPI::BulkTestResource < ZendeskAPI::DataResource
  extend ZendeskAPI::CreateMany
  extend ZendeskAPI::DestroyMany
  extend ZendeskAPI::UpdateMany
end

class ZendeskAPI::NilResource < ZendeskAPI::Data; end
class ZendeskAPI::NilDataResource < ZendeskAPI::DataResource; end
class ZendeskAPI::SingularTestResource < ZendeskAPI::SingularResource; end

# `client.greetings` should ignore this class, as it's not in the right namespace
class Greeting; end


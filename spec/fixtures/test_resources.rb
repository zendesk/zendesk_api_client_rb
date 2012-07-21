class ZendeskAPI::TestResource < ZendeskAPI::Resource
  def self.test(client)
    "hi"
  end

  class TestChild < ZendeskAPI::Resource
  end
end

class ZendeskAPI::NilResource < ZendeskAPI::Data; end

class ZendeskAPI::SingularTestResource < ZendeskAPI::SingularResource; end

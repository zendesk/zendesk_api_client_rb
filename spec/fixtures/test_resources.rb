class ZendeskAPI::TestResource < ZendeskAPI::Resource
  class TestChild < ZendeskAPI::Resource
  end
end

class ZendeskAPI::NilResource < ZendeskAPI::Data; end

class ZendeskAPI::SingularTestResource < ZendeskAPI::SingularResource; end

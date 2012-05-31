class Zendesk::TestResource < Zendesk::Resource
  class TestChild < Zendesk::Resource
  end
end

class Zendesk::NilResource < Zendesk::Data; end

class Zendesk::SingularTestResource < Zendesk::SingularResource; end

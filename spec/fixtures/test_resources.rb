class Zendesk::TestResource < Zendesk::Resource
  class TestChild < Zendesk::Resource
  end

  has_many :children, :class => :test_child
end

class Zendesk::NilResource < Zendesk::Data; end

class Zendesk::SingularTestResource < Zendesk::SingularResource; end

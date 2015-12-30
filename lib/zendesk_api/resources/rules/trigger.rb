require_relative 'actions'
require_relative 'conditions'
require_relative 'rule'

module ZendeskAPI
  class Trigger < Rule
    include Conditions
    include Actions

    self.resource_name = 'triggers'
    self.singular_resource_name = 'trigger'

    self.collection_paths = [
      'triggers',
      'triggers/active'
    ]

    self.resource_paths = ['triggers/%{id}']

    has :execution, class: 'RuleExecution'
  end
end

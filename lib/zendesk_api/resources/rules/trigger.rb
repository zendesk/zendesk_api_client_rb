require_relative 'actions'
require_relative 'conditions'
require_relative 'rule'

module ZendeskAPI
  class Trigger < Rule
    include Conditions
    include Actions

    has :execution, class: 'RuleExecution'
  end
end

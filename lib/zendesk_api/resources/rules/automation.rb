require_relative 'actions'
require_relative 'conditions'
require_relative 'rule'

module ZendeskAPI
  class Automation < Rule
    include Conditions
    include Actions

    self.resource_name = 'automations'
    self.singular_resource_name = 'automation'
    self.collection_paths = [
      'automations',
      'automations/active',
    ]
    self.resource_paths = ['automations/%{id}']
  end
end

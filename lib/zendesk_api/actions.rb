module ZendeskAPI
  module ResponseHandler
    def handle_response(response)
      if response.body.is_a?(Hash) && response.body[self.class.singular_resource_name]
        @attributes.replace(@attributes.deep_merge(response.body[self.class.singular_resource_name]))
      end
    end
  end
end

require_relative 'actions/create_many'
require_relative 'actions/destroy_many'
require_relative 'actions/update_many'

require_relative 'actions/create'
require_relative 'actions/destroy'
require_relative 'actions/read'
require_relative 'actions/update'

module ZendeskAPI
  class AnonymousRequest < CreateResource
    self.resource_name = 'anonymous_requests'

    # TODO model key?!
    self.singular_resource_name = 'request'

    self.collection_paths = ['portal/requests']

    namespace 'portal'
  end
end

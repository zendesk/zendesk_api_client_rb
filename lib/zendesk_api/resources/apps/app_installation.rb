module ZendeskAPI
  class AppInstallation < Resource
    self.resource_name = 'installations'
    self.singular_resource_name = 'installation'

    self.collection_paths = ['apps/installations']
    self.resource_paths = ['apps/installations/%{id}']

    namespace "apps"

    # Don't nest attributes
    def attributes_for_save
      attributes.changes
    end

    def handle_response(response)
      @attributes.replace(response.body) if response.body
    end
  end
end

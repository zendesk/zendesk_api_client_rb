module ZendeskAPI
  class AppInstallation < Resource
    namespace "apps"

    def self.singular_resource_name
      "installation"
    end

    # Don't nest attributes
    def attributes_for_save
      attributes.changes
    end

    def handle_response(response)
      @attributes.replace(response.body) if response.body
    end
  end
end

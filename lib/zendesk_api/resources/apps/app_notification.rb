module ZendeskAPI
  class AppNotification < CreateResource
    class << self
      def resource_path
        "apps/notify"
      end
    end

    # Don't nest attributes
    def attributes_for_save
      attributes.changes
    end

    def handle_response(response)
      @attributes.replace(response.body) if response.body.is_a?(Hash)
    end
  end
end

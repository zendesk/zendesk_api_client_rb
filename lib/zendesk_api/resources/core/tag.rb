module ZendeskAPI
  class Tag < DataResource
    include Update
    include Destroy

    self.resource_name = 'tags'
    self.singular_resource_name = 'tag'

    self.collection_paths = [
      'tags',
      'topics/%{topic_id}/tags',
      'organizations/%{organization_id}/tags',
      'users/%{user_id}/tags'
    ]

    def name; id; end
    def to_param; id; end

    def changed?
      true
    end

    def destroy!
      super do |req|
        req.body = attributes_for_save
      end
    end

    module Update
      def _save(method = :save)
        return self unless @resources

        @client.connection.post(path) do |req|
          req.body = { :tags => @resources.reject(&:destroyed?).map(&:id) }
        end

        true
      rescue Faraday::Error::ClientError => e
        if method == :save
          false
        else
          raise e
        end
      end
    end

    def path
      collection_path
    end

    def save_options
      [:put. path.format(attributes)]
    end

    def attributes_for_save
      { self.class.resource_name => [id] }
    end
  end
end

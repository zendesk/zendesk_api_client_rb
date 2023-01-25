module ZendeskAPI
  # https://developer.zendesk.com/api-reference/ticketing/ticket-management/tags/
  class Tag < DataResource
    include Update
    include Destroy

    alias :name :id
    alias :to_param :id

    def path(opts = {})
      raise "tags must have parent resource" unless association.options.parent

      super(opts.merge(:with_parent => true, :with_id => false))
    end

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
      rescue Faraday::ClientError => e
        if method == :save
          false
        else
          raise e
        end
      end
    end

    def attributes_for_save
      { self.class.resource_name => [id] }
    end
  end
end

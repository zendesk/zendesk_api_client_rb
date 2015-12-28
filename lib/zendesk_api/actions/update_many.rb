module ZendeskAPI
  module UpdateMany
    # Updates multiple resources using the update_many endpoint.
    # @param [Client] client The {Client} object to be used
    # @param [Array] ids An array of ids to update
    # @param [Hash] attributes The attributes to update resources with
    # @return [JobStatus] the {JobStatus} instance for this destroy job
    def update_many!(client, ids, attributes)
      response = client.connection.put("#{collection_path}/update_many") do |req|
        req.params = { ids: ids.join(',') }
        req.body = { singular_resource_name => attributes }

        yield req if block_given?
      end

      JobStatus.new(client).tap do |job_status|
        job_status.handle_response(response)
      end
    end
  end
end

module ZendeskAPI
  module DestroyMany
    # Destroys multiple resources using the destroy_many endpoint.
    # @param [Client] client The {Client} object to be used
    # @param [Array] ids An array of ids to destroy
    # @return [JobStatus] the {JobStatus} instance for this destroy job
    def destroy_many!(client, ids)
      response = client.connection.delete("#{collection_path}/destroy_many") do |req|
        req.params = { ids: ids.join(',') }

        yield req if block_given?
      end

      JobStatus.new(client).tap do |job_status|
        job_status.handle_response(response)
      end
    end
  end
end

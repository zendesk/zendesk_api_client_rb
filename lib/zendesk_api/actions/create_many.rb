module ZendeskAPI
  module CreateMany
    # Creates multiple resources using the create_many endpoint.
    # @param [Client] client The {Client} object to be used
    # @param [Array] attributes_array An array of resources to be created.
    # @return [JobStatus] the {JobStatus} instance for this create job
    def create_many!(client, attributes_array)
      response = client.connection.post("#{path}/create_many") do |req|
        req.body = { resource_name => attributes_array }

        yield req if block_given?
      end

      JobStatus.new(client).tap do |job_status|
        job_status.handle_response(response)
      end
    end
  end
end

module ZendeskAPI
  module DestroyMany
    # Destroys multiple resources using the destroy_many endpoint.
    # @param [Client] client The {Client} object to be used
    # @param [Array] ids An array of ids to destroy
    # @return [JobStatus] the {JobStatus} instance for this destroy job
    def destroy_many!(client, ids, association = Association.new(:class => self))
      response = client.connection.delete("#{association.generate_path}/destroy_many") do |req|
        req.params = { :ids => ids.join(',') }

        yield req if block_given?
      end

      JobStatus.new_from_response(client, response)
    end
  end
end

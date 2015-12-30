module ZendeskAPI
  class SuspendedTicket < ReadResource
    self.resource_name = 'suspended_tickets'
    self.singular_resource_name = 'suspended_ticket'

    self.resource_paths = ['suspended_tickets/%{id}']
    self.collection_paths = ['suspended_tickets']

    include Destroy

    # Recovers this suspended ticket to an actual ticket
    put :recover
  end
end

module ZendeskAPI
  class TicketForm < Resource
    self.resource_name = 'ticket_forms'
    self.singular_resource_name = 'ticket_form'
    self.collection_paths = ['ticket_forms']
    self.resource_paths = ['ticket_forms/%{id}']

    # TODO
    # post :clone
  end
end

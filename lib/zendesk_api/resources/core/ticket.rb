module ZendeskAPI
  class Ticket < Resource
    self.resource_name = 'tickets'
    self.singular_resource_name = 'ticket'
  end
end

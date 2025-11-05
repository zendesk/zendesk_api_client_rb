require "core/spec_helper"

describe ZendeskAPI::SuspendedTicket do
  def valid_attributes
    {
      :subject => "Test Ticket",
      :comment => { :value => "Help! I need somebody." },
      :requester => {
        :email => "zendesk-api-client-ruby-anonymous-#{client.config.username}",
        :name => "Anonymous User"
      }
    }
  end

  # TODO: We can't create now suspended tickets automatically via API calls,
  # which makes this tests very complicated to perform
  # it_should_be_readable :suspended_tickets
  # it_should_be_deletable :object => suspended_ticket
end

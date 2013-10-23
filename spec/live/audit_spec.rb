require 'core/spec_helper'

describe ZendeskAPI::Ticket::Audit do
  it_should_be_readable ticket, :audits

  describe ZendeskAPI::Ticket::Audit::Event, :vcr do
    it "should side-load events" do
      audit = ticket.audits(include: :users).first
      event = audit.events.first

      event.should be_instance_of(ZendeskAPI::Ticket::Audit::Event)
      event.author.should be_instance_of(ZendeskAPI::User)
    end
  end
end

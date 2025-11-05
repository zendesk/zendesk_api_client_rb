describe ZendeskAPI::Ticket::Audit do
  it_should_be_readable ticket, :audits

  describe ZendeskAPI::Ticket::Audit::Event, :vcr do
    it "should side-load events" do
      audit = ticket.audits(include: :users).first
      event = audit.events.first

      expect(event).to be_instance_of(ZendeskAPI::Ticket::Audit::Event)
      expect(event.author).to be_instance_of(ZendeskAPI::User)
    end
  end
end

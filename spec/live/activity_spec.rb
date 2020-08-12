require 'core/spec_helper'

xdescribe ZendeskAPI::Activity do
  before do
    VCR.use_cassette("ticket_activity") do
      ticket.comment = { :value => "test", :author_id => agent.id }
      ticket.save!
    end
  end

  it_should_be_readable :activities
end

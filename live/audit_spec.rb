require 'spec_helper'

describe ZendeskAPI::Ticket::Audit do
  it_should_be_readable ticket, :audits
end

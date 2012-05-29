require 'spec_helper'

describe Zendesk::Ticket::Audit do
  it_should_be_readable ticket, :audits
end

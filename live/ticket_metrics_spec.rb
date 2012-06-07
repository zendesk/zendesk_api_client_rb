require 'spec_helper'

describe ZendeskAPI::TicketMetric do
  it_should_be_readable :ticket_metrics
  it_should_be_readable ticket, :metrics
end

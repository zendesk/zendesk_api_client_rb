require 'spec_helper'

describe ZendeskAPI::TicketField do
  def valid_attributes
    { :type => "text", :title => "Age" }
  end

  it_should_be_creatable
  it_should_be_updatable :title
  it_should_be_deletable
  it_should_be_readable :ticket_fields
end

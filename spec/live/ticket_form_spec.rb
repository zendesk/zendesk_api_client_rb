require 'core/spec_helper'

describe ZendeskAPI::TicketForm, :delete_after do
  def valid_attributes
    { :name => "Ticket Form-o", :position => 9999, :active => false }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable :find => false # Deleted ticket forms are still returned from the show action
  it_should_be_readable :ticket_forms

  # TODO: clone
end

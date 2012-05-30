require 'spec_helper'

describe Zendesk::Ticket do
  def valid_attributes
    { 
      :ticket => {
        :type => "question",
        :subject => "This is a question?",
        :description => "Indeed it is!",
        :priority => "normal",
        :requester_id => user.id,
        :submitter_id => user.id
      }
    }
  end

  it_should_be_creatable
  it_should_be_updatable :subject
  it_should_be_deletable
  it_should_be_readable :tickets
  it_should_be_readable :tickets, :recent
  it_should_be_readable user, :requested_tickets
  it_should_be_readable user, :ccd_tickets
  it_should_be_readable organization, :tickets
end

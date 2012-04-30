require 'spec_helper'

describe Zendesk::Bookmark, :not_findable, :delete_after do
  def valid_attributes
    VCR.use_cassette('find_valid_ticket') do
      @ticket = client.tickets.first
    end

    raise "Can't test bookmarks without a valid ticket" unless @ticket

    { :ticket_id => @ticket.id }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable :bookmarks, :create => true
end

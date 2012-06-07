require 'spec_helper'

describe ZendeskAPI::Bookmark, :not_findable, :delete_after do
  def valid_attributes
    { :ticket_id => ticket.id }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable :bookmarks, :create => true
end

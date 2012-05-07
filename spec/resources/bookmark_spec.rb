require 'spec_helper'

describe Zendesk::Bookmark, :not_findable, :delete_after do
  def valid_attributes
    { :bookmark => { :ticket_id => ticket.id } }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable :bookmarks, :create => true
end

require 'spec_helper'

describe Zendesk::Forum, :delete_after do
  def valid_attributes
    { :forum => { :name => "My Forum", :forum_type => "articles", :access => "logged-in users" } }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  # Forum delete jobs are queued, so don't look for it
  it_should_be_deletable :find => false
  it_should_be_readable :forums, :create => true
end

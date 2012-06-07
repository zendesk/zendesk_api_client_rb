require 'spec_helper'

describe ZendeskAPI::Forum, :delete_after do
  def valid_attributes
    { :name => "My Forum", :forum_type => "articles", :access => "logged-in users", :category_id => category.id }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  # Forum delete jobs are queued, so don't look for it
  it_should_be_deletable :find => false
  it_should_be_readable :forums, :create => true
  it_should_be_readable category, :forums, :create => true
end

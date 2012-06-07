require 'spec_helper'

describe ZendeskAPI::Topic do
  def valid_attributes
    { 
      :forum_id => forum.id, :title => "My Topic",
      :body => "The mayan calendar ends December 31st. Coincidence? I think not."
    }
  end

  it_should_be_creatable
  it_should_be_updatable :title
  it_should_be_deletable :create => true
  it_should_be_readable :topics
  it_should_be_readable current_user, :topics
  it_should_be_readable forum, :topics
  #it_should_be_readable :topics, :show_many, :verb => :post, :ids => 
end

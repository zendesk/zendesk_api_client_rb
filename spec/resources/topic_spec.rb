require 'spec_helper'

describe Zendesk::Topic do
  def valid_attributes
    VCR.use_cassette('valid_forum') do
      @forum = client.forums.first
    end

    { 
      :topic => { 
        :forum_id => @forum.id, :title => "My Topic", 
        :body => "The mayan calendar ends December 31st. Coincidence? I think not." 
      } 
    } 
  end

  it_should_be_creatable
  it_should_be_updatable :title
  it_should_be_deletable :create => true
  it_should_be_readable :topics
  #it_should_be_readable :topics, :show_many, :verb => :post, :ids => 
end

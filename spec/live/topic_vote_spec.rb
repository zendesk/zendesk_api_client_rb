require 'core/spec_helper'

describe ZendeskAPI::TopicVote, :delete_after do
  def valid_attributes
    { :topic_id => topic.id }
  end

  under topic do
    it_should_be_creatable
    it_should_be_deletable
    it_should_be_readable topic, :votes, :create => true
  end
end

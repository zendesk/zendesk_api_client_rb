require 'spec_helper'

describe ZendeskAPI::Topic::TopicComment, :not_findable do
  def valid_attributes
    { :body => "Texty-text, text.", :topic_id => topic.id }
  end

  it_should_be_creatable
  it_should_be_updatable :body
  it_should_be_deletable
  it_should_be_readable topic, :comments
  it_should_be_readable current_user, :topic_comments
end

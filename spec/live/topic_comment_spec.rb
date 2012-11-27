require 'core/spec_helper'

describe ZendeskAPI::Topic::TopicComment do
  def valid_attributes
    { :body => "Texty-text, text." }
  end

  under topic do
    it_should_be_creatable
    it_should_be_updatable :body
    it_should_be_deletable
    it_should_be_readable topic, :comments
  end
end

describe ZendeskAPI::User::TopicComment do
  def valid_attributes
    { :body => "Texty-text, text."}
  end

  under current_user do
    it_should_be_readable current_user, :topic_comments
  end
end

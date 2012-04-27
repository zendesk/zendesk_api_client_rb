require 'spec_helper'

describe Zendesk::Topic::TopicComment, :not_findable do
  def valid_attributes
    { :topic_id => topic.id, :topic_comment => { :body => "Texty-text, text." } }
  end

  it_should_be_creatable
  it_should_be_updatable :body
  it_should_be_deletable
  it_should_be_readable topic, :comments
end

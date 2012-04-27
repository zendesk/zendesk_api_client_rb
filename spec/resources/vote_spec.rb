require 'spec_helper'

describe Zendesk::Vote do
  def valid_attributes
    { :topic_id => topic.id, :user_id => user.id }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable topic, :votes
end

require 'spec_helper'

describe ZendeskAPI::TopicSubscription, :delete_after do
  def valid_attributes
    { :topic_id => topic.id, :user_id => user.id }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable topic, :subscriptions, :create => true
  it_should_be_readable user, :topic_subscriptions, :create => true
end

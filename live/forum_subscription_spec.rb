require 'spec_helper'

describe ZendeskAPI::ForumSubscription, :delete_after do
  def valid_attributes
    { :forum_id => forum.id, :user_id => agent.id }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable forum, :subscriptions, :create => true
  it_should_be_readable agent, :forum_subscriptions, :create => true
end

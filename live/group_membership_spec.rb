require 'spec_helper'

describe Zendesk::GroupMembership, :delete_after do
  def valid_attributes
    { :group_id => group.id, :user_id => agent.id }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable :group_memberships
  it_should_be_readable agent, :group_memberships
end

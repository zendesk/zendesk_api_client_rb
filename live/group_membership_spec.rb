require 'spec_helper'

describe ZendeskAPI::GroupMembership, :delete_after do
  before :all do
    VCR.use_cassette("delete_existing_group_memberships_create") do
      agent.group_memberships.each(&:destroy)
    end
  end

  def valid_attributes
    { :group_id => group.id, :user_id => agent.id }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable :group_memberships
  it_should_be_readable agent, :group_memberships, :create => true
end

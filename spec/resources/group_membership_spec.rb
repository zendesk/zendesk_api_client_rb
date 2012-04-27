require 'spec_helper'

describe Zendesk::User::GroupMembership, :delete_after do
  def valid_attributes
    VCR.use_cassette('valid_group') do
      @group = client.groups.first
    end

    { :group_membership => { :group_id => @group.id }, :user_id => agent.id }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable :group_memberships
end

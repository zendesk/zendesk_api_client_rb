require 'core/spec_helper'

describe ZendeskAPI::OrganizationMembership, :delete_after do
  def valid_attributes
    { :organization_id => organization.id, :user_id => user.id }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable
  it_should_be_readable :organization_memberships
end

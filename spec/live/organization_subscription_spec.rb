require "core/spec_helper"

describe ZendeskAPI::OrganizationSubscription, :delete_after do
  before(:all) do
    VCR.use_cassette("enable_shared_tickets") do
      organization.update(shared_tickets: true)
      organization.save!
    end
    VCR.use_cassette("create_organization_membership") do
      @organization_membership = client.organization_memberships.create!(user_id: user.id, organization_id: organization.id)
    end
  end

  after(:all) do
    VCR.use_cassette("destroy_organization_membership") do
      @organization_membership.destroy
    end
    VCR.use_cassette("disable_shared_tickets") do
      organization.update(shared_tickets: false)
      organization.save!
    end
  end

  def valid_attributes
    {organization_id: organization.id, user_id: user.id}
  end

  it_should_be_creatable
  it_should_be_deletable
end

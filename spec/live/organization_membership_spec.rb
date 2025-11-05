require "core/spec_helper"

describe ZendeskAPI::OrganizationMembership, :delete_after do
  def valid_attributes
    { :organization_id => organization.id, :user_id => user.id }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable :organization_memberships

  describe "create_or_update" do
    after do
      VCR.use_cassette("create_or_update_destroy_organization_membership") do
        organization_membership.destroy
      end
    end

    context "when the organization membership already exist" do
      let!(:organization) do
        VCR.use_cassette("create_or_update_create_organization_membership") do
          client.organization_memberships.create(name: "Existing", organization_id: organization.id, user_id: user.id)
        end
      end

      before do
        VCR.use_cassette("create_or_update_existing_organization_membership") do
          ZendeskAPI::OrganizationMembership.create_or_update!(client, organization_id: organization.id, user_id: user.id)
        end
      end
    end
  end
end

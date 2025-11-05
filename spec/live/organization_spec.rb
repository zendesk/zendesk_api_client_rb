require "core/spec_helper"

describe ZendeskAPI::Organization, :delete_after do
  def valid_attributes
    { :name => "organization_name_ruby_sdk_test" }
  end

  it_should_be_creatable
  it_should_be_updatable :name, "organization_name_ruby_sdk_test_updated"
  it_should_be_deletable
  it_should_be_readable :organizations, :create => true

  describe "create_or_update" do
    after do
      VCR.use_cassette("create_or_update_destroy_organization") do
        organization.destroy
      end
    end

    context "when the organization already exist" do
      let!(:organization) do
        VCR.use_cassette("create_or_update_create_organization") do
          client.organizations.create(name: "Existing", external_id: "100")
        end
      end

      before do
        VCR.use_cassette("create_or_update_existing_organization") do
          ZendeskAPI::Organization.create_or_update!(client, name: "Updated!", external_id: "100")
        end
      end

      it "updates the existing organization" do
        VCR.use_cassette("create_or_update_find_existing_organization") do
          expect(client.organizations.find(id: organization.id).name).to eql "Updated!"
        end
      end
    end
  end

  describe "create_many and destroy_many" do
    let(:create_many_job) do
      VCR.use_cassette("create_many_organizations_job") do
        ZendeskAPI::Organization.create_many!(
          client,
          [
            { name: "one", external_id: "101" },
            { name: "two", external_id: "102" }
          ]
        ).tap do |job|
          job.reload! while job.status != "completed"
        end
      end
    end

    let(:destroy_many_job) do
      VCR.use_cassette("destroy_many_organizations_job") do
        ZendeskAPI::Organization.destroy_many!(
          client,
          create_many_job.results.map { |result| result["id"] }
        ).tap do |job|
          job.reload! while job.status != "completed"
        end
      end
    end

    # If fails, try deleting the orgs using the REPL
    it "creates many and then it can destroy many" do
      created_orgs = create_many_job.results.filter { |x| x["status"] == "Created" }

      expect(created_orgs.count).to be 2
      expect(destroy_many_job["total"]).to be 2
    end
  end

  describe "related" do
    let!(:organization) do
      VCR.use_cassette("organization_related_create_organization") do
        client.organizations.create(valid_attributes)
      end
    end

    after do
      VCR.use_cassette("organization_related_destroy_organization") do
        organization.destroy
      end
    end

    it "shows realated information" do
      VCR.use_cassette("organization_related_information") do
        expect(organization.related).to be_a ZendeskAPI::OrganizationRelated
      end
    end
  end
end

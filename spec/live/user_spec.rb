require "core/spec_helper"

describe ZendeskAPI::User, :delete_after do
  def valid_attributes
    {name: "Test U.", email: "test+#{Time.now.to_i}@example.org"}
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable :find => [:active?, false]
  it_should_be_readable :users
  it_should_be_readable organization, :users

  it "should be able to find by email" do
    VCR.use_cassette("user_find_by_email") do
      expect(client.users.search(:query => current_user.email).to_a).to eq([current_user])
    end
  end

  describe "related" do
    it "shows realated users" do
      VCR.use_cassette("current_user_related_users") do
        client.users.search(:query => current_user.email).first
        expect(current_user.related).to be_a ZendeskAPI::UserRelated
      end
    end
  end

  context "passwords", :vcr do
    let(:password) { client.config.password || ENV.fetch("PASSWORD", nil) }

    it "sets the password" do
      agent.set_password!(:password => password)
    end

    it "changes the password" do
      current_user.change_password!(:previous_password => password, :password => password)
    end
  end

  context "side-loading" do
    context "no permission set" do
      subject do
        VCR.use_cassette("user_admin_role") { client.users.find(:id => 20014182, :include => :roles) }
      end

      it "should include role" do
        if subject
          expect(subject.changes.key?(:role_id)).to be(false)
          expect(subject.role).to_not be_nil
          expect(subject.role.id).to be_nil
          expect(subject.role.name).to eq("admin")
          expect(subject.role.configuration).to_not be_nil

          expect(subject.custom_role).to be_nil
        end
      end
    end

    context "create_or_update" do
      after do
        VCR.use_cassette("create_or_update_destroy_user") do
          user.destroy
        end
      end

      context "when the user already exist" do
        let!(:user) do
          VCR.use_cassette("create_or_update_create_user") do
            client.users.create(name: "Existing", email: "unkown@example.org")
          end
        end

        before do
          VCR.use_cassette("create_or_update_existing_user") do
            ZendeskAPI::User.create_or_update!(client, name: "Updated!", email: "unkown@example.org")
          end
        end

        it "updates the existing user" do
          VCR.use_cassette("create_or_update_find_existing_user") do
            expect(client.users.find(id: user.id).name).to eql "Updated!"
          end
        end
      end
    end

    describe "create_many, update_many and destroy_many" do
      let(:create_many_users_job) do
        VCR.use_cassette("create_many_users_job") do
          ZendeskAPI::User.create_many!(
            client,
            [
              {name: "one", email: "1@example.org"},
              {name: "two", email: "2@example.org"}
            ]
          ).tap do |job|
            job.reload! while job.status != "completed"
          end
        end
      end

      let(:destroy_many_users_job) do
        VCR.use_cassette("destroy_many_users_job") do
          ZendeskAPI::User.destroy_many!(
            client,
            created_user_ids
          ).tap do |job|
            job.reload! while job.status != "completed"
          end
        end
      end

      let(:created_user_ids) do
        create_many_users_job.results.filter do |item|
          item["status"] == "Created"
        end.map(&:id)
      end

      let(:created_user_objects) do
        VCR.use_cassette("created_users_objects") do
          created_user_ids.map do |user_id|
            client.users.find(id: user_id)
          end
        end
      end

      before do
        VCR.use_cassette("update_many_users") do
          ZendeskAPI::User.update_many!(client, created_user_ids, notes: "this is a note").tap do |job|
            job.reload! while job.status != "completed"
          end
        end
      end

      # If fails, try deleting the orgs using the REPL
      it "updates all the users, and then, it deletes them properly" do
        created_user_objects.each do |user|
          expect(user.notes).to eq "this is a note"
        end

        expect(destroy_many_users_job["total"]).to be 2
      end
    end

    context "permission set" do
      subject do
        VCR.use_cassette("user_permission_set") { client.users.find(:id => 20014327, :include => :roles) }
      end

      it "should include role" do
        if subject
          expect(subject.changes.key?(:role_id)).to be(false)
          expect(subject.role).to_not be_nil
          expect(subject.role.id).to be_nil
          expect(subject.role.name).to eq("agent")

          expect(subject.custom_role).to_not be_nil
          expect(subject.custom_role.id).to eq(3692)
          expect(subject.custom_role.name).to eq("Staff")
          expect(subject.custom_role.configuration).to_not be_nil
        end
      end
    end
  end
end

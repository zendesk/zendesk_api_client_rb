require 'core/spec_helper'

describe ZendeskAPI::User, :delete_after do
  def valid_attributes
    { :name => "Test U.", :email => "test@example.org" }
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

  context "passwords", :vcr do
    let(:password) { client.config.password || ENV['PASSWORD'] }

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

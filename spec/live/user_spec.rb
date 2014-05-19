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
      client.users.search(:query => current_user.email).to_a.should == [current_user]
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
          subject.changes.key?(:role_id).should be_false
          subject.role.should_not be_nil
          subject.role.id.should be_nil
          subject.role.name.should == "admin"
          subject.role.configuration.should_not be_nil

          subject.custom_role.should be_nil
        end
      end
    end

    context "permission set" do
      subject do
        VCR.use_cassette("user_permission_set") { client.users.find(:id => 20014327, :include => :roles) }
      end

      it "should include role" do
        if subject
          subject.changes.key?(:role_id).should be_false
          subject.role.should_not be_nil
          subject.role.id.should be_nil
          subject.role.name.should == "agent"

          subject.custom_role.should_not be_nil
          subject.custom_role.id.should == 3692
          subject.custom_role.name.should == "Staff"
          subject.custom_role.configuration.should_not be_nil
        end
      end
    end
  end
end

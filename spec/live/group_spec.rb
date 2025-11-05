require "core/spec_helper"

describe ZendeskAPI::Group, :delete_after do
  def valid_attributes
    { :name => "My Group" }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable :find => [:deleted?, true]
  it_should_be_readable :groups
  it_should_be_readable :groups, :assignable

  context "with a membership" do
    before(:each) do
      VCR.use_cassette("read_ZendeskAPI::User_groups_create") do
        attrs = valid_attributes
        attrs.merge!(@default_options) if @default_options
        @object = described_class.create!(client, attrs)
        @membership = agent.group_memberships.create(:group_id => @object.id, :user_id => agent.id)
      end
    end

    after(:each) do
      VCR.use_cassette("read_ZendeskAPI::User_groups_delete") do
        @object.destroy
      end
    end

    it_should_be_readable agent, :groups
  end
end

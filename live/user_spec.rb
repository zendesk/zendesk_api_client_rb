require 'spec_helper'

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
end

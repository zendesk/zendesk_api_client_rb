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
end

require 'spec_helper'

describe ZendeskAPI::User::Identity, :delete_after do
  def valid_attributes
    { :type => "email", :value => "abcdef@example.com" }
  end

  under current_user do
    it_should_be_creatable
    it_should_be_updatable :verified, true
    it_should_be_deletable
    it_should_be_readable current_user, :identities, :create => true
  end
end

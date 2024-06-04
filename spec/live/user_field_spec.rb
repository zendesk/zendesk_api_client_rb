require 'core/spec_helper'

describe ZendeskAPI::UserField, :delete_after do
  def valid_attributes
    { :type => "text", :title => "title_ruby_sdk_test", :key => 'ruby_sdk_test_key' }
  end

  it_should_be_deletable
  it_should_be_creatable
  it_should_be_updatable :title, "updated_title_ruby_sdk_test"
  it_should_be_readable :user_fields, :create => true
end

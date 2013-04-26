require 'core/spec_helper'

describe ZendeskAPI::UserField, :delete_after do
  def valid_attributes
    { :type => "text", :title => "Age", :key => "age" }
  end

  it_should_be_creatable
  it_should_be_updatable :title, :key
  it_should_be_deletable
  it_should_be_readable :user_fields
end

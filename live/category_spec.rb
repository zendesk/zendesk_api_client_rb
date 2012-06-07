require 'spec_helper'

describe ZendeskAPI::Category, :delete_after do
  def valid_attributes
    { :name => "My Category" }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable
  it_should_be_readable :categories, :create => true
end

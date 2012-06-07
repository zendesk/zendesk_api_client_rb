require 'spec_helper'

describe ZendeskAPI::Organization, :delete_after do
  def valid_attributes
    { :name => "Awesome-O" }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable
  it_should_be_readable :organizations, :create => true
end

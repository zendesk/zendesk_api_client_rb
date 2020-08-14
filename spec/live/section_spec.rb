require 'core/spec_helper'

describe ZendeskAPI::Section, :delete_after do
  def valid_attributes
    { :name => "My Section" }
  end

  it_should_be_creatable
  it_should_be_updatable :position, 2
  it_should_be_deletable
  it_should_be_readable :categories, :create => true
end

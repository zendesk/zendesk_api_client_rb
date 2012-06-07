require 'spec_helper'

describe ZendeskAPI::Group do
  def valid_attributes
    { :name => "My Group" }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable :find => [:deleted?, true]
  it_should_be_readable :groups
  it_should_be_readable :groups, :assignable
  it_should_be_readable agent, :groups
end

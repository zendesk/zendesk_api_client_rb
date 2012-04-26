require 'spec_helper'

describe Zendesk::Group do
  def valid_attributes
    { 
      :group => {
        :name => "My Group"
      }
    }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable
  it_should_be_readable :groups
  it_should_be_readable :groups, :assignable
end

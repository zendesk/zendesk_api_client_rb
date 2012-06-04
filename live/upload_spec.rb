require 'spec_helper'

describe Zendesk::Upload, :not_findable do
  def valid_attributes
    { :file => "spec/fixtures/Argentina.gif" }
  end

  it_should_be_creatable :id => :token
end

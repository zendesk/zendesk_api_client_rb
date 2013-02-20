require 'core/spec_helper'

describe ZendeskAPI::Upload, :not_findable do
  def valid_attributes
    { :file => "spec/fixtures/Argentina.gif" }
  end

  it_should_be_creatable
  it_should_be_deletable
end

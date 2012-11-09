require 'core/spec_helper'

describe ZendeskAPI::Request do
  def valid_attributes
    {
      :subject => "This is a question!",
      :comment => { :value => "Haha, no." }
    }
  end

  it_should_be_creatable
  it_should_be_updatable :subject
  it_should_be_readable :requests
  it_should_be_readable user, :requests
end

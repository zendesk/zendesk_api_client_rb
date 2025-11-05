require "core/spec_helper"

describe ZendeskAPI::Target, :delete_after do
  def valid_attributes
    {
      type: "email_target",
      title: "Test Email Target",
      email: "hello@example.com",
      subject: "Test Target"
    }
  end

  it_should_be_readable :targets, create: :true
  it_should_be_creatable
  it_should_be_updatable :active, false
  it_should_be_deletable
end

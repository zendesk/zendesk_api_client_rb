require "core/spec_helper"

describe ZendeskAPI::UserView, :delete_after do
  def valid_attributes
    {
      title: "Overseas gold member",
      all: [
        {field: "name", operator: "is", value: "abcd"}
      ]
    }
  end

  it_should_be_readable :user_views
  it_should_be_creatable
  it_should_be_deletable
end

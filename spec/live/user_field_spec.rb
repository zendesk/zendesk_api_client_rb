require "core/spec_helper"

describe ZendeskAPI::UserField, :delete_after do
  def valid_attributes
    {type: "text", title: random_string(20), key: random_string(10)}
  end

  it_should_be_deletable marked_for_deletion: true
  it_should_be_creatable
  it_should_be_updatable :title, random_string(22)
  it_should_be_readable :user_fields, create: true
end

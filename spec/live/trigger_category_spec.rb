require "core/spec_helper"

describe ZendeskAPI::TriggerCategory, :delete_after do
  def valid_attributes
    {name: "New category"}
  end

  it_should_be_readable :trigger_categories
  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable
end

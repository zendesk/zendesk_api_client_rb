require "core/spec_helper"

describe ZendeskAPI::OrganizationField, :delete_after do
  def valid_attributes
    {:type => "text", :title => "Age", :key => random_string(5)}
  end

  it_should_be_creatable
  it_should_be_updatable :title, "key"
  it_should_be_readable :organization_fields, :create => true
  it_should_be_deletable :marked_for_deletion => true
end

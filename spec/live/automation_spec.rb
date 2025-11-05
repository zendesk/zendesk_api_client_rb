require "core/spec_helper"

describe ZendeskAPI::Automation, :delete_after do
  def valid_attributes
    {
      :title => "my test automation_ruby_sdk_test",
      :conditions => {
        :all => [{:field => "status", :operator => "is", :value => "open"}]
      },
      :actions => [{:field => "status", :value => "solved"}]
    }
  end

  it_should_be_readable :automations
  it_should_be_readable :automations, :active

  it_should_be_creatable
  it_should_be_updatable :conditions, {
    "any" => [],
    "all" => [{"field" => "status", "operator" => "is", "value" => "pending"}]
  }
  it_should_be_deletable
end

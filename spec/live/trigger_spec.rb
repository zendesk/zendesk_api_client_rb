require 'core/spec_helper'

describe ZendeskAPI::Trigger, :delete_after do
  def valid_attributes
    {
      :category_id => "9903501961242",
      :title => "my test trigger",
      :conditions => {
        :all => [{ :field => "status", :operator => "is", :value => "open" }]
      },
      :actions => [{ :field => "status", :value => "solved" }]
    }
  end

  it_should_be_readable :triggers
  it_should_be_readable :triggers, :active

  it_should_be_creatable
  it_should_be_updatable :conditions, {
    "any" => [],
    "all" => [{ "field" => "priority", "operator" => "is", "value" => "low" }]
  }
  it_should_be_deletable
end

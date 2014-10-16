require 'core/spec_helper'

describe ZendeskAPI::DynamicContent::Item, :delete_after do
  def valid_attributes
    {
      :name => "Snowboard Problem",
      :default_locale_id => 1,
      :content => "Snowboard Problem variant"
    }
  end

  it_should_be_readable :dynamic_content, :items, :create => true
  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_deletable
end

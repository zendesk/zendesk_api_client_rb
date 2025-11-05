require "core/spec_helper"

describe ZendeskAPI::Brand, :delete_after do
  def valid_attributes
    { :name => "awesomesauce_ruby_sdk_test_brand", :subdomain => "zendeskapi#{SecureRandom.hex(3)}" }
  end

  it_should_be_creatable
  it_should_be_updatable :name, "awesomesauce_ruby_sdk_updated_name"
  it_should_be_readable :brands

  # Deleted brands are still findable by id, but in the index action
  it_should_be_deletable :find => nil
end

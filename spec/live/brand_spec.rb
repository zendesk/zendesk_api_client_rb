require 'core/spec_helper'

describe ZendeskAPI::Brand, :delete_after do
  def valid_attributes
    { :name => "Awesome-O", :subdomain => "zendeskapi-#{Time.now.to_i}" }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_readable :brands

  # TODO: needs to be set inactive first
  # it_should_be_deletable
end

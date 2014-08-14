require 'core/spec_helper'

describe ZendeskAPI::Brand, :delete_after do
  def valid_attributes
    { :name => "awesomesauce", :subdomain => "zendeskapi#{SecureRandom.hex(3)}" }
  end

  it_should_be_creatable
  it_should_be_updatable :name
  it_should_be_readable :brands
  it_should_be_deletable :find => nil
end

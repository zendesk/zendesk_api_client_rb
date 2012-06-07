require 'spec_helper'

describe ZendeskAPI::MobileDevice do
  def valid_attributes
    { :device_type => "iPhone", :token => "5D41402ABC4B2A76B9719D911017C592" }
  end

  it_should_be_creatable
  it_should_be_deletable
  it_should_be_readable :mobile_devices, :create => true
end

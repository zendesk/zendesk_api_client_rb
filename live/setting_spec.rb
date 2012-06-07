require 'spec_helper'

describe ZendeskAPI::Setting do
  it_should_be_readable :settings, :path => 'account/settings'
end

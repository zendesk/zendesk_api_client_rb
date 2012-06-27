require 'spec_helper'

describe ZendeskAPI::View do
  it_should_be_readable :views
  it_should_be_readable :views, :active
end

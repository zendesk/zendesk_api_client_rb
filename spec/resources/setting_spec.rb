require 'spec_helper'

describe Zendesk::Setting do
  it_should_be_readable :settings, :path => 'account/settings'
end

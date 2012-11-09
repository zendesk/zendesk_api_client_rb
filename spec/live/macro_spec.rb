require 'core/spec_helper'

describe ZendeskAPI::Macro do
  it_should_be_readable :macros
  it_should_be_readable :macros, :active
end

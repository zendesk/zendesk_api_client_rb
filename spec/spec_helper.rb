$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

if RUBY_VERSION =~ /1.9/ && ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter "spec/"
  end
end

require 'zendesk'
require 'vcr'

RSpec.configure do |c|
  # so we can use `:vcr` rather than `:vcr => true`;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.before(:all, :vcr_off) do
    VCR.turn_off!
  end

  c.after(:all, :vcr_off) do
    VCR.turn_on!
  end

  c.extend VCR::RSpec::Macros
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
end

include WebMock::API

def valid_client
  Zendesk.configure do |config|
    config.username = "agent@zendesk.com"
    config.password = "123456"
    config.url = "http://dev.localhost:3000/api/v2"
    config.log = false
    config.retry = true
  end
end

class Zendesk::TestResource < Zendesk::Resource; end

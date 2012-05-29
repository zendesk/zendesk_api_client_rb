$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift(File.join(File.dirname(__FILE__), "macros"))

ENV['TZ'] = 'CET' # something that is not local and not utc so we find all the bugs

if RUBY_VERSION =~ /1.9/ && ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter "spec/"
  end
end

require 'zendesk'
require 'vcr'

require 'resource_macros'
require 'fixtures/zendesk'
require 'fixtures/test_resources'

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

  c.before(:each) do
    WebMock.reset!
  end

  c.extend VCR::RSpec::Macros
  c.extend ResourceMacros
end

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures/cassettes')
  c.default_cassette_options = { :record => :new_episodes, :decompress_compressed_response => true }
  c.hook_into :webmock
end

def client
  @client ||= Zendesk.configure do |config|
    config.username = "please.change"
    config.password = "me"
    config.url = "https://my.zendesk.com/api/v2"
    config.logger = Logger.new(STDOUT) if !!ENV["LOG"]
    config.retry = true
  end
end

include WebMock::API

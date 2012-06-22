$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift(File.join(File.dirname(__FILE__), "macros"))

ENV['TZ'] = 'CET' # something that is not local and not utc so we find all the bugs

if RUBY_VERSION =~ /1.9/ && ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter "spec/"
  end
end

require 'zendesk_api'
require 'vcr'
require 'logger'
require 'stringio'
require 'json'

require 'resource_macros'
require 'fixtures/zendesk'
require 'fixtures/test_resources'

# tests fail when this is included in a Module (someone else also defines client)
def client
  credentials = File.join(File.dirname(__FILE__), "fixtures", "credentials.yml")
  @client ||= begin
    client = ZendeskAPI::Client.new do |config|
      if File.exist?(credentials)
        data = YAML.load(File.read(credentials))
        config.username = data["username"]
        config.password = data["password"]
        config.url = data["url"]

        if data["url"].start_with?("http://")
          config.allow_http = true
        end
      else
        puts "using default credentials: live specs will fail."
        puts "add your credentials to spec/fixtures/credentials.yml (see: spec/fixtures/credentials.yml.example)"
        config.username = "please.change"
        config.password = "me"
        config.url = "https://my.zendesk.com/api/v2"
      end

      config.retry = true
    end

    client.config.logger.level = (ENV["LOG"] ? Logger::INFO : Logger::WARN)
    client.config.cache.size = 0

    client
  end
end

module TestHelper
  def silence_logger
    old_level = client.config.logger.level
    client.config.logger.level = 6
    yield
  ensure
    client.config.logger.level = old_level
  end

  def silence_stderr
    $stderr = File.new( '/dev/null', 'w' )
    yield
  ensure
    $stderr = STDERR
  end

  def json(body = {})
    JSON.dump(body)
  end

  def stub_json_request(verb, path_matcher, body = json, options = {})
    stub_request(verb, path_matcher).to_return(Hashie::Mash.new(
      :body => body, :headers => { :content_type => "application/json" }
    ).deep_merge(options))
  end
end

RSpec.configure do |c|
  # so we can use `:vcr` rather than `:vcr => true`;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.before(:each) do
    ZendeskAPI::TestResource.associations.clear
    ZendeskAPI::TestResource.has_many :children, :class => :test_child
  end

  c.before(:each) do
    WebMock.reset!
  end

  c.around(:each, :silence_logger) do |example|
    silence_logger{ example.call }
  end

  c.around(:each, :prevent_logger_changes) do |example|
    begin
      old_logger = client.config.logger
      example.call
    ensure
      client.config.logger = old_logger
    end
  end

  c.extend VCR::RSpec::Macros
  c.extend ResourceMacros
  c.include TestHelper
end

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), "fixtures", "cassettes")
  c.default_cassette_options = { :record => :new_episodes, :decode_compressed_response => true }
  c.hook_into :webmock
end

include WebMock::API

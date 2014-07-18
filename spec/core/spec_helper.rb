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
require 'multi_json'

begin
  require 'byebug'
rescue LoadError
end

class String
  def encoding_aware?; false; end
end

require File.join(File.dirname(__FILE__), '..', 'macros', 'resource_macros')
require File.join(File.dirname(__FILE__), '..', 'fixtures', 'zendesk')
require File.join(File.dirname(__FILE__), '..', 'fixtures', 'test_resources')

$credentials_warning = false

# tests fail when this is included in a Module (someone else also defines client)
def client
  credentials = File.join(File.dirname(__FILE__), '..', 'fixtures', 'credentials.yml')
  @client ||= begin
    client = ZendeskAPI::Client.new do |config|
      if File.exist?(credentials)
        data = YAML.load(File.read(credentials))
        config.username = data["username"]

        if data["token"]
          config.access_token = data["token"]
          config.url_based_access_token = true
        else
          config.password = data["password"]
        end

        if data["auth"]
          config.extend(Module.new do
            attr_accessor :authorization

            def options
              super.tap do |options|
                options[:headers].merge!(
                  :authorization => "Basic #{Base64.urlsafe_encode64(authorization)}"
                )
              end
            end
          end)
          config.authorization = data["auth"]
        end

        config.url = data["url"]

        if data["url"].start_with?("http://")
          config.allow_http = true
        end
      else
        unless $credentials_warning
          STDERR.puts "using default credentials: live specs will fail."
          STDERR.puts "add your credentials to spec/fixtures/credentials.yml (see: spec/fixtures/credentials.yml.example)"
          $credentials_warning = true
        end

        config.username = "please.change"
        config.password = "me"
        config.url = "https://my.zendesk.com/api/v2"
      end

      config.retry = true
    end

    client.config.logger.level = (ENV["LOG"] ? Logger::DEBUG : Logger::WARN)
    client.config.cache.size = 0
    client.callbacks.clear

    client.insert_callback do |env|
      warning = env[:response_headers]["X-Zendesk-API-Warn"]

      if warning && warning !~ /\["access_token"\]/ && client.config.logger
        client.config.logger.warn "WARNING: #{warning}"
      end
    end

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
    MultiJson.dump(body)
  end

  def stub_json_request(verb, path_matcher, body = json, options = {})
    stub_request(verb, path_matcher).to_return(Hashie::Mash.new(
      :body => body, :headers => { :content_type => "application/json", :content_length => body.size }
    ).deep_merge(options))
  end
end

RSpec.configure do |c|
  c.before(:each) do
    ZendeskAPI::TestResource.associations.clear
    ZendeskAPI::TestResource.has_many :children, :class => ZendeskAPI::TestResource::TestChild
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

  c.extend ResourceMacros
  c.extend ZendeskAPI::Fixtures
  c.include ZendeskAPI::Fixtures
  c.include TestHelper
end

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), '..', 'fixtures', 'cassettes')
  c.default_cassette_options = { :record => :new_episodes, :decode_compressed_response => true, :serialize_with => :json, :preserve_exact_body_bytes => true }
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

include WebMock::API

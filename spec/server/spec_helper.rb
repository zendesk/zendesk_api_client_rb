ENV['TZ'] = 'CET' # something that is not local and not utc so we find all the bugs
ENV['RACK_ENV'] = 'test'

require 'zendesk_api'
require 'zendesk_api/server/base'

require 'database_cleaner'
require 'rack/test'
require 'webmock'
require 'json'

module TestHelper
  def app
    ZendeskAPI::Server::App
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
  # Uneccessary in Rspec 3
  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.before(:each) do
    WebMock.reset!
  end

  c.after(:each) do
    DatabaseCleaner.clean
  end

  c.include Rack::Test::Methods
  c.include WebMock::API
  c.include TestHelper
end

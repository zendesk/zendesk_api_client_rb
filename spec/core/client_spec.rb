require 'core/spec_helper'

class SimpleClient < ZendeskAPI::Client
  def build_connection
    "FOO"
  end
end

RSpec.describe ZendeskAPI::Client do
  subject { client }

  describe "#tickets" do
    subject do
      ZendeskAPI::Client.new do |config|
        config.url = "https://example.zendesk.com/api/v2"
        config.access_token = access_token
        config.adapter = :test
        config.adapter_proc = proc do |stub|
          stub.get "/api/v2/tickets" do |_env|
            [200, { "Content-Type": "application/json" }, "null"]
          end
        end
      end
    end

    let(:access_token) { "my-access-token" }

    context "access token" do
      it "makes a call using the access token" do
        response = subject.connection.get("/api/v2/tickets")
        expect(response.env.request_headers["Authorization"]).to eq("Bearer #{access_token}")
      end
    end
  end

  context "#initialize" do
    it "should require a block" do
      expect { ZendeskAPI::Client.new }.to raise_error(ArgumentError)
    end

    it "should raise an exception when url isn't ssl" do
      expect do
        ZendeskAPI::Client.new do |config|
          config.url = "http://www.google.com"
        end
      end.to raise_error(ArgumentError)
    end

    it "should raise an exception when url is multiline and ssl" do
      expect do
        ZendeskAPI::Client.new do |config|
          config.url = "garbage\nhttps://www.google.com"
        end
      end.to raise_error(ArgumentError)
    end

    it "should not raise an exception when url isn't ssl and allow_http is set to true" do
      expect do
        ZendeskAPI::Client.new do |config|
          config.allow_http = true
          config.url = "http://www.google.com/"
        end
      end.to_not raise_error
    end

    it "should handle valid url" do
      expect do
        ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com/api/v2"
        end.to_not raise_error
      end
    end

    it "should handle valid url as a stringlike" do
      expect do
        url = Object.new

        def url.to_str
          "https://example.zendesk.com/api/v2"
        end

        ZendeskAPI::Client.new do |config|
          config.url = url
        end.to_not raise_error
      end
    end

    context "basic_auth" do
      subject do
        ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com/api/v2"
          config.username = "hello"
          config.password = "token"
        end
      end

      it "should include Request::Authorization in the handlers" do
        expect(subject.connection.builder.handlers)
          .to include(Faraday::Request::Authorization)
      end

      it "should not build token middleware" do
        expect(subject.connection.headers["Authorization"]).to be_nil
      end
    end

    context "access token" do
      subject do
        ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com/api/v2"
          config.access_token = "hello"
        end
      end

      it "should include Request::Authorization in the handlers" do
        expect(subject.connection.builder.handlers)
          .to include(Faraday::Request::Authorization)
      end
    end

    context "#token" do
      let(:client) do
        ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com/api/v2"
          config.username = username
          config.token = "token"
          config.client_options = { :request => { :timeout => 30 } }
        end
      end

      subject { client.config }
      let(:username) { "hello" }

      context "with a username with /token" do
        let(:username) { "hello/token" }

        it "should not add /token to the username" do
          expect(subject.username).to eq("hello/token")
        end
      end

      context "with no password" do
        it "should include Request::Authorization in the handlers" do
          expect(client.connection.builder.handlers)
            .to include(Faraday::Request::Authorization)
        end

        it "should copy token to password" do
          expect(subject.token).to eq(subject.password)
        end

        it "should add /token to the username" do
          expect(subject.username).to eq("hello/token")
        end
      end

      context "when username is nil" do
        let(:username) { nil }

        it "raises an exception" do
          expect { subject }.to raise_error(
            ArgumentError, "you need to provide a username when using API token auth"
          )
        end
      end

      it "should have specified timeout when provided" do
        expect(client.connection.options.timeout).to eq(30)
      end
    end

    context "#logger" do
      before(:each) do
        @client = ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com/api/v2"
          config.logger = subject
        end

        stub_request(:get, %r{/bs$}).to_return(:status => 200)
      end

      context "with true value" do
        subject { true }

        it "should log in faraday" do
          expect(@client.connection.builder.handlers).to include(ZendeskAPI::Middleware::Response::Logger)
        end

        context "with a request" do
          it "should log" do
            expect(client.config.logger).to receive(:info).at_least(:once)
            @client.connection.get('/bs')
          end
        end
      end

      context "with false value" do
        subject { false }

        it "should not log" do
          expect(@client.connection.builder.handlers).to_not include(ZendeskAPI::Middleware::Response::Logger)
        end
      end

      context "with a nil value" do
        subject { nil }

        it "should log" do
          expect(@client.connection.builder.handlers).to include(ZendeskAPI::Middleware::Response::Logger)
        end
      end

      context "with a logger" do
        let(:out) { StringIO.new }
        subject { Logger.new(out) }

        it "should log" do
          expect(@client.connection.builder.handlers).to include(ZendeskAPI::Middleware::Response::Logger)
        end

        context "with a request" do
          it "should log to the subject" do
            expect(out).to receive(:write).at_least(:once)
            @client.connection.get('/bs')
          end
        end
      end
    end
  end

  context "#current_user" do
    before(:each) do
      stub_json_request(:get, %r{users/me}, json("user" => {}))
    end

    it "should be a user instance" do
      expect(client.current_user).to be_instance_of(ZendeskAPI::User)
    end
  end

  context "#connection" do
    it "should initially be false" do
      expect(subject.instance_variable_get(:@connection)).to be_falsey
    end

    it "connection should be initialized on first call to #connection" do
      expect(subject.connection).to be_instance_of(Faraday::Connection)
    end
  end

  context "resources" do
    it "should return an instance of ZendeskAPI::Collection if there is no method" do
      expect(subject.instance_variable_get(:@resource_cache)["tickets"]).to be_nil

      expect(subject.tickets).to be_instance_of(ZendeskAPI::Collection)

      expect(subject.instance_variable_get(:@resource_cache)["tickets"]).to_not be_empty
      expect(subject.instance_variable_get(:@resource_cache)["tickets"][:class]).to eq(ZendeskAPI::Ticket)
      expect(subject.instance_variable_get(:@resource_cache)["tickets"][:cache]).to be_instance_of(ZendeskAPI::LRUCache)

      expect(ZendeskAPI).to_not receive(:const_get)
      expect(subject.tickets).to be_instance_of(ZendeskAPI::Collection)
    end

    it "should not cache calls with different options" do
      expect(subject.search(:query => 'abc')).to_not eq(subject.search(:query => '123'))
    end

    it "should not cache calls with :reload => true options" do
      expect(subject.search(:query => 'abc')).to_not eq(subject.search(:query => 'abc', :reload => true))
    end

    it "should not pass reload to the underlying collection" do
      collection = subject.search(:query => 'abc', :reload => true)
      expect(collection.options.key?(:reload)).to be(false)
    end

    it "should cache calls with the same options" do
      expect(subject.search(:query => 'abc')).to eq(subject.search(:query => 'abc'))
    end

    it "should respond_to? for valid resources" do
      expect(subject.respond_to?(:tickets)).to eq(true)
    end

    it "should respond_to? for valid cached resources" do
      subject.tickets

      expect(subject.respond_to?(:tickets)).to eq(true)
    end

    it "should respond_to? for actual instance methods" do
      expect(subject.respond_to?(:set_default_logger, true)).to eq(true)
      expect(subject.respond_to?(:set_default_logger)).to eq(false)
    end

    it "should not respond_to? invalid resources" do
      expect(subject.respond_to?(:nope)).to eq(false)
      expect(subject.respond_to?(:empty?)).to eq(false)
    end

    it "delegates voice correctly" do
      expect(subject.voice.greetings).to be_instance_of(ZendeskAPI::Collection)
    end

    it "looks in the appropriate namespaces" do
      expect(subject.greetings.association.options['class']).to eq(ZendeskAPI::Voice::Greeting)
    end

    it 'raises if the resource does not exist' do
      expect { subject.random_resource }.to raise_error(RuntimeError)
    end

    context "when use_resource_cache is set to false" do
      subject do
        ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com/api/v2"
          config.use_resource_cache = false
        end
      end

      before(:each) do
        stub_request(:get, %r{/bs$}).to_return(:status => 200)
      end

      it "returns an instance of ZendeskAPI::Collection" do
        expect(subject.tickets).to be_instance_of(ZendeskAPI::Collection)
      end

      it "does not add collection to resource_cache" do
        subject.tickets
        expect(subject.instance_variable_get(:@resource_cache)).to be_empty
      end

      it "raises if the resource does not exist" do
        expect { subject.random_resource }.to raise_error(RuntimeError)
      end
    end
  end

  it "can be subclassed" do
    client = SimpleClient.new do |config|
      config.allow_http = true
    end
    expect(client.config.allow_http).to eq(true)
    expect(client.connection).to eq("FOO")
    expect(client.connection.object_id).to eq(client.connection.object_id) # it's cached
  end

  context ZendeskAPI::Voice do
    it "defers to voice delegator" do
      expect(subject).to receive(:phone_numbers).once
      subject.voice.phone_numbers
    end

    it "manages namespace correctly" do
      expect(client.addresses.path).to match(/channels\/voice\/addresses/)
      expect(client.phone_numbers.path).to match(/channels\/voice\/phone_numbers/)
      expect(client.greetings.path).to match(/channels\/voice\/greetings/)
      expect(client.greeting_categories.path).to match(/channels\/voice\/greeting_categories/)
    end
  end
end

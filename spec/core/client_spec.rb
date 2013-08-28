require 'core/spec_helper'

class SimpleClient < ZendeskAPI::Client
  def build_connection
    "FOO"
  end
end

describe ZendeskAPI::Client do
  subject { client }

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
          config.url = "https://example.zendesk.com/"
        end.to_not raise_error
      end
    end

    context "basic_auth" do
      subject do
        ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com"
          config.username = "hello"
          config.password = "token"
        end
      end

      it "should build basic auth middleware" do
        subject.connection.builder.handlers.index(Faraday::Request::BasicAuthentication).should_not be_nil
      end

      it "should not build token middleware" do
        subject.connection.headers["Authorization"].should be_nil
      end
    end

    context "access token" do
      subject do
        ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com"
          config.access_token = "hello"
        end
      end

      it "should not build basic auth middleware" do
        subject.connection.builder.handlers.index(Faraday::Request::BasicAuthentication).should be_nil
      end

      it "should build token middleware" do
        subject.connection.headers["Authorization"].should match(/Bearer/)
      end
    end

    context "#token" do
      let(:client) do
        ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com"
          config.username = username
          config.token = "token"
        end
      end

      subject { client.config }
      let(:username) { "hello" }

      context "with a username with /token" do
        let(:username) { "hello/token" }

        it "should not add /token to the username" do
          subject.username.should == "hello/token"
        end
      end

      context "with no password" do
        it "should build basic auth middleware" do
          client.connection.builder.handlers.index(Faraday::Request::BasicAuthentication).should_not be_nil
        end

        it "should not build token middleware" do
          client.connection.builder.handlers.index(Faraday::Request::TokenAuthentication).should be_nil
        end

        it "should copy token to password" do
          subject.token.should == subject.password
        end

        it "should add /token to the username" do
          subject.username.should == "hello/token"
        end
      end
    end

    context "#logger" do
      before(:each) do
        @client = ZendeskAPI::Client.new do |config|
          config.url = "https://example.zendesk.com/"
          config.logger = subject
        end

        stub_request(:get, %r{/bs$}).to_return(:status => 200)
      end

      context "with true value" do
        subject { true }

        it "should log in faraday" do
          @client.connection.builder.handlers.should include(ZendeskAPI::Middleware::Response::Logger)
        end

        context "with a request" do
          it "should log" do
            client.config.logger.should_receive(:info).at_least(:once)
            @client.connection.get('/bs')
          end
        end
      end

      context "with false value" do
        subject { false }

        it "should not log" do
          @client.connection.builder.handlers.should_not include(ZendeskAPI::Middleware::Response::Logger)
        end
      end

      context "with a nil value" do
        subject { nil }

        it "should log" do
          @client.connection.builder.handlers.should include(ZendeskAPI::Middleware::Response::Logger)
        end
      end

      context "with a logger" do
        let(:out){ StringIO.new }
        subject { Logger.new(out) }

        it "should log" do
          @client.connection.builder.handlers.should include(ZendeskAPI::Middleware::Response::Logger)
        end

        context "with a request" do
          it "should log to the subject" do
            out.should_receive(:write).at_least(:once)
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
      client.current_user.should be_instance_of(ZendeskAPI::User)
    end
  end

  context "#connection" do
    it "should initially be false" do
      subject.instance_variable_get(:@connection).should be_false
    end

    it "connection should be initialized on first call to #connection" do
      subject.connection.should be_instance_of(Faraday::Connection)
    end
  end

  context "resources" do
    it "should return an instance of ZendeskAPI::Collection if there is no method" do
      subject.instance_variable_get(:@resource_cache)["tickets"].should be_nil

      subject.tickets.should be_instance_of(ZendeskAPI::Collection)

      subject.instance_variable_get(:@resource_cache)["tickets"].should_not be_empty
      subject.instance_variable_get(:@resource_cache)["tickets"][:class].should == ZendeskAPI::Ticket
      subject.instance_variable_get(:@resource_cache)["tickets"][:cache].should be_instance_of(ZendeskAPI::LRUCache)

      ZendeskAPI.should_not_receive(:const_get)
      subject.tickets.should be_instance_of(ZendeskAPI::Collection)
    end

    it "should not cache calls with different options" do
      subject.search(:query => 'abc').should_not == subject.search(:query => '123')
    end

    it "should not cache calls with :reload => true options" do
      subject.search(:query => 'abc').should_not == subject.search(:query => 'abc', :reload => true)
    end

    it "should not pass reload to the underlying collection" do
      collection = subject.search(:query => 'abc', :reload => true)
      collection.options.key?(:reload).should be_false
    end

    it "should cache calls with the same options" do
      subject.search(:query => 'abc').should == subject.search(:query => 'abc')
    end
  end

  it "can be subclassed" do
    client = SimpleClient.new do |config|
      config.allow_http = true
    end
    client.config.allow_http.should == true
    client.connection.should == "FOO"
    client.connection.object_id.should == client.connection.object_id # it's cached
  end

  context ZendeskAPI::Voice do
    it "defers to voice delegator" do
      ZendeskAPI::Client.any_instance.should_receive(:phone_numbers).once
      subject.voice.phone_numbers
    end

    it "manages namespace correctly" do
      ZendeskAPI::Voice::PhoneNumber.new(subject, {}).path.should match(/channels\/voice\/phone_numbers/)
    end
  end
end

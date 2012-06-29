require 'spec_helper'

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
          @client.connection.builder.handlers.should include(Faraday::Response::Logger)
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
          @client.connection.builder.handlers.should_not include(Faraday::Response::Logger)
        end
      end

      context "with a nil value" do
        subject { nil }

        it "should log" do
          @client.connection.builder.handlers.should include(Faraday::Response::Logger)
        end
      end

      context "with a logger" do
        let(:out){ StringIO.new }
        subject { Logger.new(out) }
        
        it "should log" do
          @client.connection.builder.handlers.should include(Faraday::Response::Logger)
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
      subject.tickets.should be_instance_of(ZendeskAPI::Collection)
      subject.instance_variable_defined?(:@tickets).should be_true
    end
  end

  context "#play" do
    # TODO may be able to be replaced by VCR
    before(:each) do 
      stub_request(:get, %r{play}).to_return do
        { :status => 302 }
      end
    end

    it "should return an instance of ZendeskAPI::Playlist" do
      subject.play(1).should be_instance_of(ZendeskAPI::Playlist)
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
end

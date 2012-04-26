require 'spec_helper'

describe Zendesk::Client do
  subject { valid_client }

  context "#configure" do
    it "should require a block" do
      expect { Zendesk.configure }.to raise_error(Zendesk::ConfigurationException)
    end

    it "should raise an exception when url isn't ssl and is not localhost" do
      expect do
        Zendesk.configure do |config|
          config.url = "http://www.google.com"
        end
      end.to raise_error(Zendesk::ConfigurationException) 
    end

    it "should not raise an exception when url isn't ssl and is localhost" do
      expect do
        Zendesk.configure do |config|
          config.url = "https://127.0.0.1/"
        end
      end.to_not raise_error

      expect do
        Zendesk.configure do |config|
          config.url = "https://localhost/"
        end
      end.to_not raise_error
    end

    it "should handle valid url" do
      expect do
        Zendesk.configure do |config|
          config.url = "https://example.zendesk.com/"
        end.to_not raise_error
      end
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
    it "should return an instance of Zendesk::Collection if there is no method" do
      subject.tickets.should be_instance_of(Zendesk::Collection)
      subject.instance_variable_defined?(:@tickets).should be_true
    end
  end

  context "#play", :vcr_off do
    # TODO may be able to be replaced by VCR
    before(:each) do 
      stub_request(:get, %r{play.json}).to_return do
        { :status => 302 }
      end
    end

    it "should return an instance of Zendesk::Playlist" do
      subject.play(1).should be_instance_of(Zendesk::Playlist)
    end
  end
end

require 'core/spec_helper'

describe ZendeskAPI::Rescue do
  include ZendeskAPI::Rescue

  class Boom
    include ZendeskAPI::Rescue
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def puff(error)
      if error.is_a?(Class)
        raise error, "Puff"
      else
        raise error
      end
    end

    def boom(error)
      raise error, "Boom"
    end

    rescue_client_error :puff
  end

  it "rescues from client errors", :silence_logger do
    Boom.new(client).puff(Faraday::Error::ClientError)
  end

  it "does not protect other actions" do
    expect{
      Boom.new(client).boom(RuntimeError)
    }.to raise_error RuntimeError
  end

  it "raises everything else" do
    expect{
      Boom.new(client).puff(RuntimeError)
    }.to raise_error RuntimeError
  end

  it "logs to logger" do
    out = StringIO.new
    client = ZendeskAPI::Client.new do |config|
      config.logger = Logger.new(out)
      config.url = "https://idontcare.com"
    end
    out.should_receive(:write).at_least(:twice)
    Boom.new(client).puff(Faraday::Error::ClientError)
  end

  it "does crash without logger" do
    client = ZendeskAPI::Client.new do |config|
      config.logger = false
      config.url = "https://idontcare.com"
    end
    Boom.new(client).puff(Faraday::Error::ClientError)
  end

  context "when class has error attributes", :silence_logger do
    let(:instance) { Boom.new(client) }

    let(:exception) do
      exception = Exception.new("message")
      exception.set_backtrace([])
      exception
    end

    let(:error) do
      Faraday::Error::ClientError.new(exception, response)
    end

    before do
      Boom.send(:attr_accessor, :error, :error_message)
      instance.puff(error)
    end

    context "with no response" do
      let(:response) {{}}

      it "should attach the error" do
        instance.error.should_not be_nil
      end

      it "should not attach the message" do
        instance.error_message.should be_nil
      end
    end

    context "with a response" do
      let(:response) {{ :body => { :error => { :description => "hello" } } }}

      it "should attach the error" do
        instance.error.should_not be_nil
      end

      it "should attach the error message" do
        instance.error_message.should_not be_nil
      end

      context "and again with no response" do
        before do
          instance.puff(Faraday::Error::ClientError.new(exception, {}))
        end

        it "should clear the error message" do
          instance.error_message.should be_nil
        end
      end
    end
  end

  context "passing a block" do
    it "rescues from client errors", :silence_logger do
      rescue_client_error do
        raise Faraday::Error::ClientError, "error"
      end
    end

    it "raises everything else" do
      expect{
        rescue_client_error { raise RuntimeError, "error" }
      }.to raise_error RuntimeError
    end

    it "logs to logger" do
      out = StringIO.new
      @client = ZendeskAPI::Client.new do |config|
        config.logger = Logger.new(out)
        config.url = "https://idontcare.com"
      end
      out.should_receive(:write).at_least(:twice)
      rescue_client_error do
        raise Faraday::Error::ClientError, "error"
      end
    end

    it "does crash without logger" do
      @client = ZendeskAPI::Client.new do |config|
        config.logger = false
        config.url = "https://idontcare.com"
      end
      rescue_client_error do
        raise Faraday::Error::ClientError, "error"
      end
    end
  end
end

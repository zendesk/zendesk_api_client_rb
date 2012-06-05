require 'spec_helper'

describe Zendesk::Rescue do
  class Boom
    extend Zendesk::Rescue
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def puff(error)
      raise error, "Puff"
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
    client = Zendesk.configure do |config|
      config.logger = Logger.new(out)
      config.url = "https://idontcare.com"
    end
    out.should_receive(:write).at_least(:twice)
    Boom.new(client).puff(Faraday::Error::ClientError)
  end

  it "does crash without logger" do
    client = Zendesk.configure do |config|
      config.logger = false
      config.url = "https://idontcare.com"
    end
    Boom.new(client).puff(Faraday::Error::ClientError)
  end
end

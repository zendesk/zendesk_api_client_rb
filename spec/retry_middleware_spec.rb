require 'spec_helper'

describe Zendesk::Request::RetryMiddleware, :vcr_off do
  let(:client) { valid_client }


  context "on 429 [rate-limit]" do
    before(:each) do
      stub_request(:get, %r{blergh}).to_return(:status => 429,
                                               :headers => { :retry_after => 1 }).
                                               to_return(:status => 200)
    end

    it "should wait requisite seconds and then retry request" do
      client.connection.get("blergh").status.should == 200
    end
  end

  context "on 503" do
    before(:each) do
      stub_request(:get, %r{blergh}).to_return(:status => 503).
        to_return(:status => 200)
    end

    it "should wait 10 seconds and then retry request" do
      client.connection.get("blergh").status.should == 200
    end
  end


end

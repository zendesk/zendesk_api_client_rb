require 'spec_helper'

describe Zendesk::Request::RetryMiddleware, :vcr_off do
  let(:client) { valid_client }

  before(:each) do
    stub_request(:get, %r{blergh}).to_return(:status => 429,
                                                     :headers => { :retry_after => 1 }).
                                                     to_return(:status => 200)
  end

  it "should wait requisite seconds and then retry request" do
    Zendesk::Request::RetryMiddleware.any_instance.should_receive(:sleep).at_least(:once)
    client.connection.get("blergh").status.should == 200
  end

end

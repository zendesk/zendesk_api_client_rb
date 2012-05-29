require 'spec_helper'

describe Zendesk::Middleware::Request::Retry, :vcr_off do
  def runtime
    start = Time.now.to_f
    yield
    Time.now.to_f - start
  end

  [429, 503].each do |error_code|
    it "should wait requisite seconds and then retry request on #{error_code}" do
      stub_request(:get, %r{blergh}).
        to_return(:status => 429, :headers => { :retry_after => 1 }).
        to_return(:status => 200)

      runtime do
        client.connection.get("blergh").status.should == 200
      end.should be_within(0.2).of(1)
    end
  end

  it "should wait default timeout seconds and then retry request on error" do
    stub_request(:get, %r{blergh}).
      to_return(:status => 503).
      to_return(:status => 200)

    Zendesk::Middleware::Request::Retry.any_instance.should_receive(:sleep).exactly(10).times.with(1)

    runtime do
      client.connection.get("blergh").status.should == 200
    end.should <= 0.5
  end
end

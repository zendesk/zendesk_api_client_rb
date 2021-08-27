require 'core/spec_helper'

describe ZendeskAPI::Middleware::Request::Retry do
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

      seconds = runtime {
        expect(client.connection.get("blergh").status).to eq(200)
      }

      expect(seconds).to be_within(0.2).of(1)
    end
  end

  context "with a failed connection" do
    context "connection failed" do
      before(:each) do
        stub_request(:any, /.*/).to_raise(Faraday::ConnectionFailed)
      end

      it "should raise NetworkError, but actually retry" do
        expect_any_instance_of(ZendeskAPI::Middleware::Request::Retry).to receive(:sleep).exactly(10).times.with(1)
        expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::NetworkError)
      end
    end
  end

  [503].each do |error_code|
    context "with failing request because server is not ready with default error code #{error_code}", :prevent_logger_changes do
      before do
        stub_request(:get, %r{blergh}).
          to_return(:status => error_code).
          to_return(:status => 200)

        expect_any_instance_of(ZendeskAPI::Middleware::Request::Retry).to receive(:sleep).exactly(10).times.with(1)
      end

      it "should wait default timeout seconds and then retry request on error" do
        expect(runtime {
          expect(client.connection.get("blergh").status).to eq(200)
        }).to be <= 0.5
      end

      it "should print to logger" do
        expect(client.config.logger).to receive(:warn).exactly(4)
        client.connection.get("blergh")
      end

      it "should not fail without a logger" do
        client.config.logger = false
        client.connection.get("blergh")
      end
    end
  end
end

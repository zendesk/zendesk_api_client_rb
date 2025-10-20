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

  context "with a failed connection and not retrying" do
    context "connection failed" do
      before(:each) do
        stub_request(:any, /.*/).to_raise(Faraday::ConnectionFailed)
      end

      it "should raise NetworkError, but never retry" do
        expect_any_instance_of(ZendeskAPI::Middleware::Request::Retry).to receive(:sleep).exactly(10).never
        expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::NetworkError)
      end
    end
  end

  context "with a failed connection, explicit retry true  on exception, and retrying" do
    context "connection failed" do
      before(:each) do
        client.config.retry_on_exception = true
        stub_request(:any, /.*/).to_raise(Faraday::ConnectionFailed).to_return(:status => 200)
      end

      it "should raise NetworkError, but then actually retry" do
        expect_any_instance_of(ZendeskAPI::Middleware::Request::Retry).to receive(:sleep).exactly(10).times.with(1)
        expect(client.connection.get("blergh").status).to eq(200)
      end
    end
  end

  context "with a failed connection, explicit retry false on exception, and retrying" do
    context "connection failed" do
      before(:each) do
        client.config.retry_on_exception = false
        stub_request(:any, /.*/).to_raise(Faraday::ConnectionFailed).to_return(:status => 200)
      end

      it "should raise NetworkError, but never retry" do
        expect_any_instance_of(ZendeskAPI::Middleware::Request::Retry).to receive(:sleep).exactly(10).never
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

  [501, 503].each do |error_code|
    context "with failing request because server is not ready with default error code #{error_code}", :prevent_logger_changes do
      before do
        client.config.retry_codes = [501, 503]
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

  context "with instrumentation on retry" do
    let(:instrumentation) { double("Instrumentation") }
    let(:middleware) do
      ZendeskAPI::Middleware::Request::Retry.new(client.connection.builder.app)
    end

    before do
      allow(instrumentation).to receive(:instrument)
      client.config.instrumentation = instrumentation
      # Inject instrumentation into middleware instance
      allow_any_instance_of(ZendeskAPI::Middleware::Request::Retry).to receive(:instrumentation).and_return(instrumentation)
      stub_request(:get, %r{instrumented}).to_return(:status => 429, :headers => { :retry_after => 1 }).to_return(:status => 200)
    end

    it "calls instrumentation on retry" do
      expect(instrumentation).to receive(:instrument).with(
        "zendesk.retry",
        hash_including(:attempt, :endpoint, :method, :reason, :delay)
      ).at_least(:once)
      client.connection.get("instrumented")
    end

    it "does not call instrumentation when no retry occurs" do
      stub_request(:get, %r{no_retry}).to_return(:status => 200)
      expect(instrumentation).not_to receive(:instrument).with(
        "zendesk.retry",
        hash_including(:attempt, :endpoint, :method, :reason, :delay)
      )
      client.connection.get("no_retry")
    end
  end
end

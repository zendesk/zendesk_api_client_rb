describe ZendeskAPI::Middleware::Request::Retry do
  def runtime
    start = Time.now.to_f
    yield
    Time.now.to_f - start
  end

  [429, 503].each do |error_code|
    it "should wait requisite seconds and then retry request on #{error_code}" do
      stub_request(:get, %r{blergh})
        .to_return(status: 429, headers: {retry_after: 1})
        .to_return(status: 200)

      seconds = runtime {
        expect(client.connection.get("blergh").status).to eq(200)
      }

      expect(seconds).to be_within(0.3).of(1)
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
        stub_request(:any, /.*/).to_raise(Faraday::ConnectionFailed).to_return(status: 200)
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
        stub_request(:any, /.*/).to_raise(Faraday::ConnectionFailed).to_return(status: 200)
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
        stub_request(:get, %r{blergh})
          .to_return(status: error_code)
          .to_return(status: 200)

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
        client.config.logger = nil
        client.connection.get("blergh")
      end
    end
  end

  [501, 503].each do |error_code|
    context "with failing request because server is not ready with default error code #{error_code}", :prevent_logger_changes do
      before do
        client.config.retry_codes = [501, 503]
        stub_request(:get, %r{blergh})
          .to_return(status: error_code)
          .to_return(status: 200)

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
        client.config.logger = nil
        client.connection.get("blergh")
      end
    end
  end

  describe 'instrumentation' do
    let(:events) { [] }

    let(:instrumentation) do
      store = events
      Object.new.tap do |obj|
        obj.define_singleton_method(:instrument) do |event, payload|
          store << [event, payload]
        end
      end
    end

    before do
      client.config.instrumentation = instrumentation
      client.instance_variable_set(:@connection, nil)
      allow_any_instance_of(ZendeskAPI::Middleware::Request::Retry).to receive(:sleep)
    end

    after do
      client.config.instrumentation = nil
      client.instance_variable_set(:@connection, nil)
      events.clear
    end

    def retry_events
      # rubocop:disable Style/HashSlice
      events.select { |event, _payload| event == 'zendesk.retry' }
      # rubocop:enable Style/HashSlice
    end

    it 'emits retry instrumentation with incremented attempt for rate limits' do
      stub_request(:get, %r{instrument_retry}).
        to_return(:status => 429, :headers => { :retry_after => 1 }).
        to_return(:status => 200)

      client.connection.get('instrument_retry')

      event = retry_events.first
      expect(event).not_to be_nil
      payload = event.last
      expect(payload[:attempt]).to eq(2)
      expect(payload[:reason]).to eq('rate_limited')
      expect(payload[:delay]).to eq(1)
      expect(payload[:endpoint]).to end_with('/instrument_retry')
    end

    it 'emits retry instrumentation with service_unavailable reason' do
      stub_request(:get, %r{service_retry}).
        to_return(:status => 503).
        to_return(:status => 200)

      client.connection.get('service_retry')

      event = retry_events.first
      expect(event).not_to be_nil
      payload = event.last
      expect(payload[:reason]).to eq('service_unavailable')
      expect(payload[:delay]).to eq(10)
    end

    it 'emits retry instrumentation for exceptions when retry_on_exception is enabled' do
      client.config.retry_on_exception = true

      stub_request(:any, /.*/).
        to_raise(Faraday::ConnectionFailed).to_return(:status => 200)

      client.connection.get('exception_retry')

      event = retry_events.first
      expect(event).not_to be_nil
      payload = event.last
      expect(payload[:reason]).to eq('exception')
      expect(payload[:attempt]).to eq(2)
    ensure
      client.config.retry_on_exception = false
    end

    context 'without instrumentation configured' do
      before do
        client.config.instrumentation = nil
        client.instance_variable_set(:@connection, nil)
      end

      it 'performs retries without emitting events' do
        stub_request(:get, %r{no_instrumentation}).
          to_return(:status => 429, :headers => { :retry_after => 1 }).
          to_return(:status => 200)

        client.connection.get('no_instrumentation')

        expect(retry_events).to be_empty
      end
    end

    context 'when instrumentation raises errors' do
      before do
        failing = Object.new.tap do |obj|
          obj.define_singleton_method(:instrument) do |_event, _payload|
            raise 'boom'
          end
        end

        client.config.instrumentation = failing
        client.instance_variable_set(:@connection, nil)
      end

      it 'swallows instrumentation failures and logs at debug level' do
        logger = client.config.logger
        expect(logger).to receive(:debug).at_least(:once)

        stub_request(:get, %r{failing_retry}).
          to_return(:status => 429, :headers => { :retry_after => 1 }).
          to_return(:status => 200)

        expect { client.connection.get('failing_retry') }.not_to raise_error
      end
    end
  end
end

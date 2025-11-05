describe ZendeskAPI::Middleware::Request::EtagCache do
  it "caches" do
    client.config.cache.size = 1

    stub_json_request(:get, %r{blergh}, '{"x":1}', headers: {"Etag" => "x"})
    first_response = client.connection.get("blergh")
    expect(first_response.status).to eq(200)
    expect(first_response.body).to eq({"x" => 1})

    stub_request(:get, %r{blergh}).to_return(status: 304, headers: {"Etag" => "x"})
    response = client.connection.get("blergh")
    expect(response.status).to eq(304)
    expect(response.body).to eq({"x" => 1})

    %w[content_encoding content_type content_length etag].each do |header|
      expect(response.headers[header]).to eq(first_response.headers[header])
    end
  end

  describe 'instrumentation' do
    before do
      @previous_cache = client.config.cache
      client.config.cache = ZendeskAPI::LRUCache.new(5)
    end

    after do
      client.config.instrumentation = nil
      client.instance_variable_set(:@connection, nil)
      client.config.cache = @previous_cache
    end

    it 'emits cache miss event when caching a fresh response' do
      stub_json_request(:get, %r{cache_miss}, '{"x":1}', :headers => { 'Etag' => 'abc' })

      events = capture_instrumentation_events do
        client.config.instrumentation = ActiveSupport::Notifications
        client.connection.get('cache_miss')
      end

      event_name, payload = find_event(events, 'zendesk.cache_miss')
      expect(event_name).to eq('zendesk.cache_miss')

      aggregate_failures 'cache miss payload' do
        expect(payload[:endpoint]).to end_with('/cache_miss')
        expect(payload[:status]).to eq(200)
      end
    end

    it 'emits cache hit event when serving from cache' do
      stub_json_request(:get, %r{cache_hit}, '{"x":1}', :headers => { 'Etag' => 'abc' })

      # First request to populate cache (outside instrumentation capture)
      client.config.instrumentation = ActiveSupport::Notifications
      client.connection.get('cache_hit')

      stub_request(:get, %r{cache_hit})
        .to_return(:status => 304, :headers => { 'Etag' => 'abc' })

      # Second request should hit cache
      events = capture_instrumentation_events do
        client.connection.get('cache_hit')
      end

      event_name, payload = find_event(events, 'zendesk.cache_hit')
      expect(event_name).to eq('zendesk.cache_hit')

      aggregate_failures 'cache hit payload' do
        expect(payload[:endpoint]).to end_with('/cache_hit')
        expect(payload[:status]).to eq(304)
      end
    end

    it 'does not emit events for non-cacheable requests' do
      stub_request(:post, %r{no_cache}).to_return(:status => 200)

      events = capture_instrumentation_events do
        client.config.instrumentation = ActiveSupport::Notifications
        client.connection.post('no_cache')
      end

      aggregate_failures 'no cache events for POST' do
        expect(filter_events(events, 'zendesk.cache_hit')).to be_empty
        expect(filter_events(events, 'zendesk.cache_miss')).to be_empty
      end
    end

    context 'without instrumentation configured' do
      it 'performs caching without emitting events' do
        stub_json_request(:get, %r{no_instrument_cache}, '{"x":1}', :headers => { 'Etag' => 'abc' })

        # Don't configure instrumentation
        expect { client.connection.get('no_instrument_cache') }.not_to raise_error
      end
    end

    context 'when instrumentation raises errors' do
      let(:erroring_instrumentation) do
        Object.new.tap do |obj|
          obj.define_singleton_method(:instrument) do |_event, _payload|
            raise 'boom'
          end
        end
      end

      it 'swallows instrumentation failures' do
        stub_json_request(:get, %r{failing_cache}, '{"x":1}', :headers => { 'Etag' => 'abc' })

        client.config.instrumentation = erroring_instrumentation
        expect { client.connection.get('failing_cache') }.not_to raise_error
      end
    end
  end
end

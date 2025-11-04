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
      @previous_cache = client.config.cache
      client.config.cache = ZendeskAPI::LRUCache.new(5)
      client.config.instrumentation = instrumentation
      client.instance_variable_set(:@connection, nil)
    end

    after do
      client.config.instrumentation = nil
      client.instance_variable_set(:@connection, nil)
      client.config.cache = @previous_cache
      events.clear
    end

    def cache_events(name)
      events.select { |event, _payload| event == name }
    end

    it 'emits cache miss event when caching a fresh response' do
      stub_json_request(:get, %r{cache_miss}, '{"x":1}', :headers => { 'Etag' => 'abc' })

      client.connection.get('cache_miss')

      event = cache_events('zendesk.cache_miss').first
      expect(event).not_to be_nil
      payload = event.last
      expect(payload[:endpoint]).to end_with('/cache_miss')
      expect(payload[:status]).to eq(200)
    end

    it 'emits cache hit event when serving from cache' do
      stub_json_request(:get, %r{cache_hit}, '{"x":1}', :headers => { 'Etag' => 'abc' })
      client.connection.get('cache_hit')

      stub_request(:get, %r{cache_hit})
        .to_return(:status => 304, :headers => { 'Etag' => 'abc' })

      client.connection.get('cache_hit')

      event = cache_events('zendesk.cache_hit').first
      expect(event).not_to be_nil
      payload = event.last
      expect(payload[:endpoint]).to end_with('/cache_hit')
      expect(payload[:status]).to eq(304)
    end

    it 'does not emit events for non-cacheable requests' do
      stub_request(:post, %r{no_cache}).to_return(:status => 200)

      client.connection.post('no_cache')

      expect(cache_events('zendesk.cache_hit')).to be_empty
      expect(cache_events('zendesk.cache_miss')).to be_empty
    end

    context 'without instrumentation configured' do
      before do
        client.config.instrumentation = nil
        client.instance_variable_set(:@connection, nil)
      end

      it 'performs caching without emitting events' do
        stub_json_request(:get, %r{no_instrument_cache}, '{"x":1}', :headers => { 'Etag' => 'abc' })

        client.connection.get('no_instrument_cache')

        expect(events).to be_empty
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

      it 'swallows instrumentation failures' do
        stub_json_request(:get, %r{failing_cache}, '{"x":1}', :headers => { 'Etag' => 'abc' })

        expect { client.connection.get('failing_cache') }.not_to raise_error
      end
    end
  end
end

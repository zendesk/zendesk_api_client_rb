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

  context 'instrumentation' do
    let(:instrumentation) { double('instrumentation') }
    let(:cache) { ZendeskAPI::LRUCache.new(5) }
    let(:middleware) do
      ZendeskAPI::Middleware::Request::EtagCache.new(
        ->(env) { Faraday::Response.new(env) },
        cache: cache,
        instrumentation: instrumentation
      )
    end
    let(:env) do
      {
        url: URI('https://example.zendesk.com/api/v2/tickets'),
        method: :get,
        request_headers: {},
        response_headers: { 'Etag' => 'abc' },
        status: status,
        body: { 'x' => 1 }
      }
    end

    before do
      allow(instrumentation).to receive(:instrument)
    end

    context 'on cache miss' do
      let(:status) { 200 }

      it 'emits cache_miss event' do
        expect(instrumentation).to receive(:instrument).with(
          'zendesk.cache_miss',
          hash_including(endpoint: '/api/v2/tickets', status: 200)
        )
        middleware.call(env).on_complete { |_e| }
      end
    end

    context 'on cache hit' do
      let(:status) { 304 }

      it 'emits cache_hit event' do
        cache.write(middleware.cache_key(env), env)
        expect(instrumentation).to receive(:instrument).with(
          'zendesk.cache_hit',
          hash_including(endpoint: '/api/v2/tickets', status: 304)
        )
        middleware.call(env).on_complete { |_e| }
      end
    end
  end
end

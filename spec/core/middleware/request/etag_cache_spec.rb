require "core/spec_helper"

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

  context "instrumentation" do
    let(:instrumenter) { TestInstrumenter.new }
    let(:cache) { ZendeskAPI::LRUCache.new(5) }
    let(:middleware) do
      ZendeskAPI::Middleware::Request::EtagCache.new(
        ->(env) { Faraday::Response.new(env) },
        cache: cache,
        instrumentation: instrumenter
      )
    end
    let(:env) do
      {
        url: URI("https://example.zendesk.com/api/v2/blergh"),
        method: :get,
        request_headers: {},
        response_headers: {"Etag" => "x"},
        status: nil,
        body: {"x" => 1},
        response_body: {"x" => 1}
      }
    end

    it "instruments cache miss on first request" do
      env[:status] = 200
      middleware.call(env).on_complete { |_e| }

      cache_events = instrumenter.find_events("zendesk.cache_miss")
      expect(cache_events.size).to eq(1)

      event = cache_events.first[:payload]
      expect(event[:endpoint]).to eq("/api/v2/blergh")
      expect(event[:status]).to eq(200)
    end

    it "instruments cache hit on 304 response" do
      cache.write(middleware.cache_key(env), env)
      env[:status] = 304
      middleware.call(env).on_complete { |_e| }

      cache_events = instrumenter.find_events("zendesk.cache_hit")
      expect(cache_events.size).to eq(1)

      event = cache_events.first[:payload]
      expect(event[:endpoint]).to eq("/api/v2/blergh")
      expect(event[:status]).to eq(304)
    end

    it "does not crash when instrumentation is nil" do
      no_instrumentation_middleware = ZendeskAPI::Middleware::Request::EtagCache.new(
        ->(env) { Faraday::Response.new(env) },
        cache: cache,
        instrumentation: nil
      )

      env[:status] = 200
      expect { no_instrumentation_middleware.call(env).on_complete { |_e| } }.not_to raise_error
    end
  end
end

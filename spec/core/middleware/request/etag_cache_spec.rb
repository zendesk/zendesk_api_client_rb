require 'core/spec_helper'
require 'active_support/cache'

describe ZendeskAPI::Middleware::Request::EtagCache do
  it "caches" do
    client.config.cache.size = 1

    stub_json_request(:get, %r{blergh}, '{"x":1}', :headers => { "Etag" => "x" })
    first_response = client.connection.get("blergh")
    expect(first_response.status).to eq(200)
    expect(first_response.body).to eq({ "x" => 1 })

    stub_request(:get, %r{blergh}).to_return(:status => 304, :headers => { "Etag" => "x" })
    response = client.connection.get("blergh")
    expect(response.status).to eq(304)
    expect(response.body).to eq({ "x" => 1 })

    %w{content_encoding content_type content_length etag}.each do |header|
      expect(response.headers[header]).to eq(first_response.headers[header])
    end
  end

  context "instrumentation" do
    let(:instrumentation) { double("Instrumentation") }
    let(:cache) { ActiveSupport::Cache::MemoryStore.new }
    let(:status) { nil }
    let(:middleware) do
      ZendeskAPI::Middleware::Request::EtagCache.new(
        ->(env) { Faraday::Response.new(env) },
        cache: cache,
        instrumentation: instrumentation
      )
    end
    let(:env) do
      {
        url: URI("https://example.zendesk.com/api/v2/blergh"),
        method: :get,
        request_headers: {},
        response_headers: { "Etag" => "x", x_rate_limit_remaining: 10 },
        status: status,
        body: { "x" => 1 },
        response_body: { "x" => 1 }
      }
    end
    let(:no_instrumentation_middleware) do
      ZendeskAPI::Middleware::Request::EtagCache.new(
        ->(env) { Faraday::Response.new(env) },
        cache: cache,
        instrumentation: nil
      )
    end
    before do
      allow(instrumentation).to receive(:instrument)
    end

    it "emits cache_miss on first request" do
      expect(instrumentation).to receive(:instrument).with(
        "zendesk.cache_miss",
        hash_including(endpoint: "/api/v2/blergh", status: 200)
      )
      env[:status] = 200
      middleware.call(env).on_complete { |_e| 1 }
    end

    it "don't care on no instrumentation" do
      env[:status] = 200
      no_instrumentation_middleware.call(env).on_complete { |_e| 1 }
    end

    it "emits cache_hit on 304 response" do
      cache.write(middleware.cache_key(env), env)
      expect(instrumentation).to receive(:instrument).with(
        "zendesk.cache_hit",
        hash_including(endpoint: "/api/v2/blergh", status: 304)
      )
      env[:status] = 304
      middleware.call(env).on_complete { |_e| 1 }
    end
  end
end

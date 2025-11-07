require "core/spec_helper"
require "faraday"
require "zendesk_api/middleware/response/zendesk_request_event"

RSpec.describe ZendeskAPI::Middleware::Response::ZendeskRequestEvent do
  let(:app) { ->(env) { Faraday::Response.new(env) } }
  let(:logger) { Logger.new(File::NULL) }
  let(:instrumenter) { TestInstrumenter.new }
  let(:middleware) { described_class.new(app, instrumentation: instrumenter, logger: logger) }
  let(:response_headers) do
    {
      "X-Rate-Limit-Remaining" => "10",
      "X-Rate-Limit" => "100",
      "X-Rate-Limit-Reset" => "1234567890"
    }
  end
  let(:env) do
    {
      url: URI("https://example.zendesk.com/api/v2/tickets"),
      method: :get,
      status: status,
      response_headers: response_headers
    }
  end

  context "when the response status is less than 500" do
    let(:status) { 200 }

    it "instruments both zendesk.request and zendesk.rate_limit" do
      middleware.call(env).on_complete { |_response_env| }

      request_events = instrumenter.find_events("zendesk.request")
      expect(request_events.size).to eq(1)

      request_payload = request_events.first[:payload]
      expect(request_payload[:duration]).to be > 0
      expect(request_payload[:endpoint]).to eq("/api/v2/tickets")
      expect(request_payload[:method]).to eq(:get)
      expect(request_payload[:status]).to eq(200)

      rate_limit_events = instrumenter.find_events("zendesk.rate_limit")
      expect(rate_limit_events.size).to eq(1)

      rate_limit_payload = rate_limit_events.first[:payload]
      expect(rate_limit_payload[:endpoint]).to eq("/api/v2/tickets")
      expect(rate_limit_payload[:status]).to eq(200)
      expect(rate_limit_payload[:remaining]).to eq("10")
      expect(rate_limit_payload[:limit]).to eq("100")
      expect(rate_limit_payload[:reset]).to eq("1234567890")
    end
  end

  context "when the response status is 500 or greater" do
    let(:status) { 500 }

    it "instruments only zendesk.request, not zendesk.rate_limit" do
      middleware.call(env).on_complete { |_response_env| }

      request_events = instrumenter.find_events("zendesk.request")
      expect(request_events.size).to eq(1)

      request_payload = request_events.first[:payload]
      expect(request_payload[:status]).to eq(500)

      rate_limit_events = instrumenter.find_events("zendesk.rate_limit")
      expect(rate_limit_events).to be_empty
    end
  end

  context "when rate limit headers are missing" do
    let(:status) { 200 }
    let(:response_headers) { {} }

    it "instruments request but not rate_limit" do
      middleware.call(env).on_complete { |_response_env| }

      request_events = instrumenter.find_events("zendesk.request")
      expect(request_events.size).to eq(1)

      rate_limit_events = instrumenter.find_events("zendesk.rate_limit")
      expect(rate_limit_events).to be_empty
    end
  end

  context "when instrumentation is nil" do
    let(:status) { 200 }
    let(:middleware) { described_class.new(app, instrumentation: nil, logger: logger) }

    it "does not raise an error" do
      expect { middleware.call(env).on_complete { |_response_env| } }.not_to raise_error
    end

    it "does not instrument any events" do
      middleware.call(env).on_complete { |_response_env| }

      expect(instrumenter.events).to be_empty
    end
  end

  context "when instrumentation raises an error" do
    let(:status) { 200 }

    it "rescues the error and logs it" do
      allow(instrumenter).to receive(:instrument).and_raise("Instrumentation error")

      expect(logger).to receive(:debug)

      middleware.call(env).on_complete { |_response_env| }
    end
  end
end

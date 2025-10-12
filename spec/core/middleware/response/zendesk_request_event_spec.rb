require_relative '../../../spec_helper'
require 'faraday'
require 'zendesk_api/middleware/response/zendesk_request_event'

RSpec.describe ZendeskAPI::Middleware::Response::ZendeskRequestEvent do
  let(:instrumentation) { double('Instrumentation') }
  let(:client) do
    double('Client', config: double('Config', instrumentation: instrumentation))
  end
  let(:app) { ->(env) { Faraday::Response.new(env) } }
  let(:middleware) { described_class.new(app, client) }
  let(:response_headers) do
    {
      x_rate_limit_remaining: 10,
      x_rate_limit: 100,
      x_rate_limit_reset: 1234567890
    }
  end
  let(:env) do
    {
      url: URI('https://example.zendesk.com/api/v2/tickets'),
      method: :get,
      status: status,
      response_headers: response_headers
    }
  end

  before do
    allow(instrumentation).to receive(:instrument)
  end

  context 'when the response status is less than 500' do
    let(:status) { 200 }

    it 'instruments zendesk.request and zendesk.rate_limit' do
      expect(instrumentation).to receive(:instrument).with(
        'zendesk.request',
        hash_including(:duration, endpoint: '/api/v2/tickets', method: :get, status: 200)
      )
      expect(instrumentation).to receive(:instrument).with(
        'zendesk.rate_limit',
        hash_including(endpoint: '/api/v2/tickets', status: 200)
      )
      middleware.call(env).on_complete { |_response_env| 1 }
    end
  end

  context 'when the response status is 500 or greater' do
    let(:status) { 500 }

    it 'instruments only zendesk.request' do
      expect(instrumentation).to receive(:instrument).with(
        'zendesk.request',
        hash_including(:duration, endpoint: '/api/v2/tickets', method: :get, status: 500)
      )
      expect(instrumentation).not_to receive(:instrument).with('zendesk.rate_limit', anything)
      middleware.call(env).on_complete { |_response_env| 1 }
    end
  end

  context 'duration calculation' do
    let(:status) { 201 }

    it 'passes a positive duration to instrumentation' do
      expect(instrumentation).to receive(:instrument) do |event, payload|
        if event == 'zendesk.request'
          expect(payload[:duration]).to be > 0
        end
      end
      expect(instrumentation).to receive(:instrument).with('zendesk.rate_limit', anything)
      middleware.call(env).on_complete { |_response_env| 1 }
    end
  end

  context 'when instrumentation is nil' do
    let(:status) { 200 }
    let(:client) do
      double('Client', config: double('Config', instrumentation: nil))
    end
    let(:middleware) { described_class.new(app, client) }

    it 'does not raise an error' do
      expect { middleware.call(env).on_complete { |_response_env| 1 } }.not_to raise_error
    end
  end
end

require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::InstrumentRequest do
  let(:instrumentation) { double('instrumentation') }
  let(:client_double) { double('client', config: double('config', instrumentation: instrumentation)) }
  let(:middleware) { described_class.new(app, client_double) }
  let(:app) { ->(env) { Faraday::Response.new(env) } }
  let(:env) do
    {
      url: URI('https://example.zendesk.com/api/v2/tickets'),
      method: :get,
      status: 200,
      response_headers: {
        'X-Rate-Limit-Remaining' => '10',
        'X-Rate-Limit' => '100'
      }
    }
  end

  before do
    allow(instrumentation).to receive(:instrument)
  end

  it 'emits request event with duration' do
    expect(instrumentation).to receive(:instrument).with(
      'zendesk.request',
      hash_including(endpoint: '/api/v2/tickets', method: :get, status: 200, duration: kind_of(Numeric))
    )
    middleware.call(env).on_complete { |_e| }
  end

  it 'emits rate_limit event when headers present' do
    expect(instrumentation).to receive(:instrument).with(
      'zendesk.rate_limit',
      hash_including(endpoint: '/api/v2/tickets', status: 200, remaining: 10, threshold: 100)
    )
    middleware.call(env).on_complete { |_e| }
  end

  context 'when status is 500+' do
    let(:env) do
      {
        url: URI('https://example.zendesk.com/api/v2/tickets'),
        method: :get,
        status: 503,
        response_headers: {}
      }
    end

    it 'does not emit rate_limit or request events' do
      expect(instrumentation).not_to receive(:instrument)
      middleware.call(env).on_complete { |_e| }
    end
  end
end

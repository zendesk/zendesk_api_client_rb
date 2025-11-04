require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::InstrumentRequest do
  let(:events) { [] }

  let(:instrumentation) do
    store = events
    Object.new.tap do |obj|
      obj.define_singleton_method(:instrument) do |event, payload|
        store << [event, payload]
      end
    end
  end

  let(:current_instrumentation) { instrumentation }

  before do
    client.config.instrumentation = current_instrumentation
    client.instance_variable_set(:@connection, nil)
  end

  after do
    client.config.instrumentation = nil
    client.instance_variable_set(:@connection, nil)
    events.clear
  end

  def request_event
    events.find { |event, _payload| event == 'zendesk.request' }
  end

  def rate_limit_event
    events.find { |event, _payload| event == 'zendesk.rate_limit' }
  end

  it 'emits request instrumentation with duration' do
    stub_json_request(:get, /instrumented/, '{}')

    client.connection.get('instrumented')

    event = request_event
    expect(event).not_to be_nil
    payload = event.last
    expect(payload[:duration]).to be > 0.0
    expect(payload[:endpoint]).to end_with('/instrumented')
    expect(payload[:method]).to eq(:get)
    expect(payload[:status]).to eq(200)
  end

  it 'emits rate limit instrumentation when headers are present' do
    stub_request(:get, /rate_limit/)
      .to_return(:status => 200,
                 :body => '{}',
                 :headers => {
                   'Content-Type' => 'application/json',
                   'X-Rate-Limit-Remaining' => '23',
                   'X-Rate-Limit' => '100'
                 })

    client.connection.get('rate_limit')

    event = rate_limit_event
    expect(event).not_to be_nil
    payload = event.last
    expect(payload[:remaining]).to eq(23)
    expect(payload[:threshold]).to eq(100)
    expect(payload[:endpoint]).to end_with('/rate_limit')
  end

  it 'does not emit rate limit events for server errors' do
    stub_request(:get, /rate_limit_error/)
      .to_return(:status => 503,
                 :body => '{}',
                 :headers => {
                   'Content-Type' => 'application/json',
                   'X-Rate-Limit-Remaining' => '0',
                   'X-Rate-Limit' => '100'
                 })

    expect { client.connection.get('rate_limit_error') }
      .to raise_error(ZendeskAPI::Error::NetworkError)

    expect(rate_limit_event).to be_nil
    expect(request_event).to be_nil
  end

  context 'without instrumentation configured' do
    let(:current_instrumentation) { nil }

    it 'performs the request without emitting events' do
      stub_json_request(:get, /no_instrument/, '{}')

      expect { client.connection.get('no_instrument') }.not_to raise_error

      expect(events).to be_empty
    end
  end

  context 'when instrumentation raises errors' do
    let(:current_instrumentation) do
      Object.new.tap do |obj|
        obj.define_singleton_method(:instrument) do |_event, _payload|
          raise 'boom'
        end
      end
    end

    it 'swallows errors and logs at debug level' do
      logger = client.config.logger
      expect(logger).to receive(:debug).at_least(:once)

      stub_json_request(:get, /erroring/, '{}')

      expect { client.connection.get('erroring') }.not_to raise_error
    end
  end
end

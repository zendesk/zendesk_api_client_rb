# frozen_string_literal: true

require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::InstrumentRequest do
  before do
    # Force connection rebuild to pick up instrumentation config
    allow(client).to receive(:connection).and_wrap_original do |method|
      method.call.tap { client.instance_variable_set(:@connection, nil) }
    end
  end

  after do
    client.config.instrumentation = nil
    client.instance_variable_set(:@connection, nil)
  end

  it 'emits request instrumentation with duration' do
    stub_json_request(:get, /instrumented/, '{}')

    events = capture_instrumentation_events do
      client.config.instrumentation = ActiveSupport::Notifications
      client.connection.get('instrumented')
    end

    event_name, payload = find_event(events, 'zendesk.request')
    expect(event_name).to eq('zendesk.request')

    aggregate_failures 'request payload' do
      expect(payload[:duration]).to be > 0.0
      expect(payload[:endpoint]).to end_with('/instrumented')
      expect(payload[:method]).to eq(:get)
      expect(payload[:status]).to eq(200)
    end
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

    events = capture_instrumentation_events do
      client.config.instrumentation = ActiveSupport::Notifications
      client.connection.get('rate_limit')
    end

    event_name, payload = find_event(events, 'zendesk.rate_limit')
    expect(event_name).to eq('zendesk.rate_limit')

    aggregate_failures 'rate limit payload' do
      expect(payload[:remaining]).to eq(23)
      expect(payload[:threshold]).to eq(100)
      expect(payload[:endpoint]).to end_with('/rate_limit')
    end
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

    events = capture_instrumentation_events do
      client.config.instrumentation = ActiveSupport::Notifications
      expect { client.connection.get('rate_limit_error') }
        .to raise_error(ZendeskAPI::Error::NetworkError)
    end

    aggregate_failures 'no events emitted' do
      expect(find_event(events, 'zendesk.rate_limit')).to be_nil
      expect(find_event(events, 'zendesk.request')).to be_nil
    end
  end

  context 'without instrumentation configured' do
    it 'performs the request without emitting events' do
      stub_json_request(:get, /no_instrument/, '{}')

      # Don't configure instrumentation
      expect { client.connection.get('no_instrument') }.not_to raise_error
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

    it 'swallows errors and logs at debug level' do
      logger = client.config.logger
      expect(logger).to receive(:debug).at_least(:once)

      stub_json_request(:get, /erroring/, '{}')

      client.config.instrumentation = erroring_instrumentation
      expect { client.connection.get('erroring') }.not_to raise_error
    end
  end
end

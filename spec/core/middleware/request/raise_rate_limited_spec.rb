require 'core/spec_helper'

describe ZendeskAPI::Middleware::Request::RaiseRateLimited do
  before do
    client.config.retry = false
    client.config.raise_error_when_rate_limited = true

    stub_request(:get, /blergh/).
      to_return(status: 429)
  end

  it 'should raise RateLimited' do
    expect do
      client.connection.get('blergh')
    end.to raise_error(ZendeskAPI::Error::RateLimited)
  end

  it 'should print to logger' do
    expect(client.config.logger).to receive(:warn)
    client.connection.get('blergh') rescue ZendeskAPI::Error::RateLimited # rubocop:disable Style/RescueModifier
  end

  it 'should not fail without a logger', :prevent_logger_changes do
    client.config.logger = false
    client.connection.get('blergh') rescue ZendeskAPI::Error::RateLimited # rubocop:disable Style/RescueModifier
  end
end

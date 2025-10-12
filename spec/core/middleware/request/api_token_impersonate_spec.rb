require 'core/spec_helper'

RSpec.describe ZendeskAPI::Middleware::Request::ApiTokenImpersonate do
  let(:app) { ->(env) { env } }
  let(:middleware) { described_class.new(app) }
  let(:username) { 'impersonated_user' }
  let(:token) { 'abc123' }
  let(:original_username) { 'original_user/token' }
  let(:encoded_auth) { Base64.urlsafe_encode64("#{original_username}:#{token}") }
  let(:env) do
    {
      request_headers: {
        authorization: "Basic #{encoded_auth}"
      }
    }
  end

  after { Thread.current[:zendesk_thread_local_username] = nil }

  context 'when local_username is set and authorization is a valid API token' do
    it 'impersonates the user by modifying the Authorization header' do
      Thread.current[:zendesk_thread_local_username] = username
      result = middleware.call(env)
      new_auth = result[:request_headers][:authorization]
      decoded = Base64.urlsafe_decode64(new_auth.split.last)
      expect(decoded).to eq("#{username}/token:#{token}")
    end
  end

  context 'when local_username is not set' do
    it 'does not modify the Authorization header' do
      result = middleware.call(env)
      expect(result[:request_headers][:authorization]).to eq(env[:request_headers][:authorization])
    end
  end

  context 'when authorization header is not Basic' do
    it 'does not modify the Authorization header' do
      Thread.current[:zendesk_thread_local_username] = username
      env[:request_headers][:authorization] = 'Bearer something'
      result = middleware.call(env)
      expect(result[:request_headers][:authorization]).to eq('Bearer something')
    end
  end

  context 'when authorization does not contain /token:' do
    it 'raises an error' do
      Thread.current[:zendesk_thread_local_username] = username
      env[:request_headers][:authorization] = "Basic #{Base64.urlsafe_encode64('user:abc123')}"
      result = middleware.call(env)
      expect(result[:request_headers][:authorization]).to eq("Basic #{Base64.urlsafe_encode64('user:abc123')}")
    end
  end

  context 'when authorization is not in valid format' do
    it 'raises an error' do
      Thread.current[:zendesk_thread_local_username] = username
      env[:request_headers][:authorization] = "Basic #{Base64.urlsafe_encode64('user/token:abc123:extra')}"
      result = middleware.call(env)
      expect(result[:request_headers][:authorization]).to eq("Basic #{Base64.urlsafe_encode64('user/token:abc123:extra')}")
    end
  end
end

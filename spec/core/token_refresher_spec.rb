require "core/spec_helper"

describe ZendeskAPI::TokenRefresher do
  let(:refresh_token_body) do
    {
      access_token: "newacc123",
      refresh_token: "newref123",
      token_type: "bearer",
      scope: "read write",
      expires_in: 300,
      refresh_token_expires_in: 604800
    }
  end
  let(:subject) { ZendeskAPI::TokenRefresher }

  before do
    client.config.client_id = "client"
    client.config.client_secret = "secret"
    client.config.refresh_token = "ref123"
    client.config.access_token = "acc123"
  end

  describe "when refreshing token succeeds" do
    let(:refresh_token_status) { 200 }

    before do
      stub_request(:post, %r{/oauth/tokens}).to_return(
        status: refresh_token_status,
        body: refresh_token_body.to_json,
        headers: {content_type: "application/json"}
      )
    end

    it "refreshes token" do
      subject.new(client.config).refresh_token

      assert_requested :post, %r{oauth/tokens}
      expect(client.config.access_token).to eq "newacc123"
      expect(client.config.refresh_token).to eq "newref123"
    end

    it "yields new tokens to provided block" do
      new_access_token = nil
      new_refresh_token = nil
      subject.new(client.config).refresh_token do |access_token, refresh_token|
        new_access_token = access_token
        new_refresh_token = refresh_token
      end

      expect(new_access_token).to eq "newacc123"
      expect(new_refresh_token).to eq "newref123"
    end

    it "does not include expiration params when not configured" do
      subject.new(client.config).refresh_token

      assert_requested(:post, %r{oauth/tokens}) do |req|
        expect(req.body).to_not match(/expires_in/)
        expect(req.body).to_not match(/refresh_token_expires_in/)
      end
    end

    it "includes expiration params when configured" do
      client.config.access_token_expiration = 300
      client.config.refresh_token_expiration = 604800
      subject.new(client.config).refresh_token

      assert_requested(:post, %r{oauth/tokens}) do |req|
        expect(req.body).to match(/expires_in/)
        expect(req.body).to match(/refresh_token_expires_in/)
      end
    end
  end

  describe "with client id not configuration" do
    before do
      client.config.client_id = nil
    end

    it "does not try to refresh token" do
      block_called = false
      subject.new(client.config).refresh_token { block_called = true }

      refute_requested :post, %r{/oauth/tokens}
      expect(block_called).to be_falsey
      expect(client.config.access_token).to eq "acc123"
      expect(client.config.refresh_token).to eq "ref123"
    end
  end

  describe "with client secret not configuration" do
    before do
      client.config.client_secret = nil
    end

    it "does not try to refresh token" do
      block_called = false
      subject.new(client.config).refresh_token { block_called = true }

      refute_requested :post, %r{/oauth/tokens}
      expect(block_called).to be_falsey
      expect(client.config.access_token).to eq "acc123"
      expect(client.config.refresh_token).to eq "ref123"
    end
  end

  describe "with client secret not configuration" do
    before do
      client.config.refresh_token = nil
    end

    it "does not try to refresh token" do
      block_called = false
      subject.new(client.config).refresh_token { block_called = true }

      refute_requested :post, %r{oauth/tokens}
      expect(block_called).to be_falsey
      expect(client.config.access_token).to eq "acc123"
    end
  end

  describe "when refreshing token fails" do
    let(:refresh_token_status) { 500 }

    before do
      stub_request(:post, %r{/oauth/tokens}).to_return(
        status: refresh_token_status,
        body: refresh_token_body.to_json,
        headers: {content_type: "application/json"}
      )
    end

    it "does not change token configuration" do
      block_called = false
      expect { subject.new(client.config).refresh_token { block_called = true } }.to raise_error(ZendeskAPI::Error::NetworkError)

      assert_requested :post, %r{oauth/tokens}
      expect(block_called).to be_falsey
      expect(client.config.access_token).to eq "acc123"
      expect(client.config.refresh_token).to eq "ref123"
    end
  end
end

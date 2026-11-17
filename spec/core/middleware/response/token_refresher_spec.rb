require "core/spec_helper"

describe ZendeskAPI::Middleware::Response::TokenRefresher do
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

  before do
    client.config.client_id = "client"
    client.config.client_secret = "secret"
    client.config.refresh_token = "ref123"
    client.config.auto_refresh_tokens = true
  end

  describe "with access token" do
    before do
      client.config.access_token = "acc123"
    end

    describe "when unauthorized" do
      before do
        stub_request(:any, /whatever/).to_return(
          status: 401,
          body: "",
          headers: {content_type: "application/json"}
        )
        stub_request(:post, %r{/oauth/tokens}).to_return(
          status: refresh_token_status,
          body: refresh_token_body.to_json,
          headers: {content_type: "application/json"}
        )
      end

      describe "when refreshing token succeeds" do
        let(:refresh_token_status) { 200 }

        it "refreshes token" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          expect(client.config.access_token).to eq "newacc123"
          expect(client.config.refresh_token).to eq "newref123"
        end

        it "calls refresh tokens callback" do
          new_access_token = nil
          new_refresh_token = nil
          client.config.refresh_tokens_callback = lambda do |access_token, refresh_token|
            new_access_token = access_token
            new_refresh_token = refresh_token
          end
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          expect(new_access_token).to eq "newacc123"
          expect(new_refresh_token).to eq "newref123"
        end

        it "is ok when refresh tokens callback is not configured" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)
          expect(client.config.access_token).to eq "newacc123"
          expect(client.config.refresh_token).to eq "newref123"
        end

        it "raises unauthorized exception" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)
        end
      end

      describe "when refreshing token fails" do
        let(:refresh_token_status) { 500 }

        it "does not update configuration" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::NetworkError)

          expect(client.config.access_token).to eq "acc123"
          expect(client.config.refresh_token).to eq "ref123"
        end
      end

      describe "when auto token refreshing is disabled" do
        let(:refresh_token_status) { 200 }

        before do
          client.config.auto_refresh_tokens = false
        end

        it "does not refresh token" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          expect_any_instance_of(ZendeskAPI::TokenRefresher).to receive(:refresh_token).never
          expect(client.config.access_token).to eq "acc123"
          expect(client.config.refresh_token).to eq "ref123"
        end
      end
    end

    describe "when status request is ok" do
      before do
        stub_request(:any, /whatever/).to_return(
          status: 200,
          body: "",
          headers: {content_type: "application/json"}
        )
      end

      it "does not refresh token" do
        client.connection.get "/whatever"

        expect_any_instance_of(ZendeskAPI::TokenRefresher).to receive(:refresh_token).never
        expect(client.config.access_token).to eq "acc123"
      end
    end
  end

  describe "with other type of authorization" do
    before do
      client.config.username = "xyz"
      client.config.password = "xyz"

      stub_request(:any, /whatever/).to_return(
        status: 401,
        body: "",
        headers: {content_type: "application/json"}
      )
    end

    it "does not refresh tokens" do
      expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

      expect_any_instance_of(ZendeskAPI::TokenRefresher).to receive(:refresh_token).never
    end
  end
end

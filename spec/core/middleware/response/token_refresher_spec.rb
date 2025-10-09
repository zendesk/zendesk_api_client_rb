require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::TokenRefresher do
  let(:refresh_token_body) do
    {
      access_token: "nt",
      refresh_token: "nrt",
      token_type: "bearer",
      scope: "read write",
      expires_in: 300,
      refresh_token_expires_in: 604800
    }
  end

  before do
    client.config.client_id = "client"
    client.config.client_secret = "secret"
    client.config.refresh_token = "abc"
  end

  describe "with access token" do
    before do
      client.config.access_token = "xyz"
    end

    describe "when unauthorized" do
      before do
        stub_request(:any, /whatever/).to_return(
          status: 401,
          body: "",
          headers: { content_type: "application/json" }
        )
      end

      describe "when refreshing token succeeds" do
        let(:refresh_token_status) { 200 }

        before do
          stub_request(:post, %r{/oauth/tokens}).to_return(
            status: refresh_token_status,
            body: refresh_token_body.to_json,
            headers: { content_type: "application/json" }
          )
        end

        it "refreshes token" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          assert_requested :post, %r{oauth/tokens}
          expect(client.config.access_token).to eq "nt"
          expect(client.config.refresh_token).to eq "nrt"
        end

        it "calls refresh token callback" do
          new_access_token = nil
          new_refresh_token = nil
          client.config.refresh_token_callback = lambda do |access_token, refresh_token|
            new_access_token = access_token
            new_refresh_token = refresh_token
          end
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          expect(new_access_token).to eq "nt"
          expect(new_refresh_token).to eq "nrt"
        end

        it "does not include expiration params when not configured" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          assert_requested(:post, %r{oauth/tokens}) do |req|
            expect(req.body).to_not match(/expires_in/)
            expect(req.body).to_not match(/refresh_token_expires_in/)
          end
        end

        it "includes expiration params when configured" do
          client.config.access_token_expiration = 300
          client.config.refresh_token_expiration = 604800
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          assert_requested(:post, %r{oauth/tokens}) do |req|
            expect(req.body).to match(/expires_in/)
            expect(req.body).to match(/refresh_token_expires_in/)
          end
        end

        it "raises unauthorized exception" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)
        end
      end

      describe "with client id not configuration" do
        before do
          client.config.client_id = nil
        end

        it "does not try to refresh token" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          refute_requested :post, %r{/oauth/tokens}
          expect(client.config.access_token).to eq "xyz"
        end
      end

      describe "with client secret not configuration" do
        before do
          client.config.client_secret = nil
        end

        it "does not try to refresh token" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          refute_requested :post, %r{/oauth/tokens}
          expect(client.config.access_token).to eq "xyz"
        end
      end

      describe "with client secret not configuration" do
        before do
          client.config.refresh_token = nil
        end

        it "does not try to refresh token" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

          refute_requested :post, %r{oauth/tokens}
          expect(client.config.access_token).to eq "xyz"
        end
      end

      describe "when refreshing token fails" do
        let(:refresh_token_status) { 500 }

        before do
          stub_request(:post, %r{/oauth/tokens}).to_return(
            status: refresh_token_status,
            body: refresh_token_body.to_json,
            headers: { content_type: "application/json" }
          )
        end

        it "does not change token configuration" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::NetworkError)

          assert_requested :post, %r{oauth/tokens}
          expect(client.config.access_token).to eq "xyz"
          expect(client.config.refresh_token).to eq "abc"
        end
      end
    end

    describe "when ok" do
      before do
        stub_request(:any, /whatever/).to_return(
          status: 200,
          body: "",
          headers: { content_type: "application/json" }
        )
      end

      it "succeeds" do
        result = client.connection.get "/whatever"
        expect(result.status).to eq 200
      end

      it "does not refresh token" do
        client.connection.get "/whatever"

        refute_requested :post, %r{oauth/tokens}
        expect(client.config.access_token).to eq "xyz"
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
        headers: { content_type: "application/json" }
      )

      stub_request(:post, %r{/oauth/tokens}).to_return(
        status: 200,
        body: refresh_token_body.to_json,
        headers: { content_type: "application/json" }
      )
    end

    it "refreshes token" do
      expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::Unauthorized)

      refute_requested :post, %r{oauth/tokens}
    end
  end
end

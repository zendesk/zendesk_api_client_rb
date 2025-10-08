require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::RaiseError do
  let(:refresh_token_body) do
    {
      access_token: "nt",
      refresh_token: "nrt",
      token_type: "bearer",
      scope: "read write",
      expires_in: 300,
      refresh_token_expires_in: 604800,
    }
  end

  describe "with access token" do
    before do
      client.config.access_token = "xyz"
    end

    before(:each) do
      stub_request(:any, /whatever/).to_return(
        status: status,
        body: "",
        headers: { content_type: "application/json" }
      )
    end

    describe "when unauthorized" do
      let(:status) { 401 }

      describe "when refreshing token succeeds" do
        let(:refresh_token_status) { 200 }

        before do
          stub_request(:post, /oauth\/tokens/).to_return(
            status: refresh_token_status,
            body: refresh_token_body.to_json,
            headers: { content_type: "application/json" }
          )
        end

        it "refreshes token" do
        end

        it "should raise Unauthorized" do
          expect { client.connection.get "/whatever" }.to raise_error(ZendeskAPI::Error::RecordNotFound)
        end
      end
    end

    describe "when ok" do
      let(:status) { 200 }

      it "succeeds" do
        result = client.connection.get "/whatever"
        expect(result.status).to eq 200
      end

      it "does not refresh token" do
      end
    end
  end

  describe "with other type of authorization" do

  end
end

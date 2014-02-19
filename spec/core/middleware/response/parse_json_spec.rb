require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::ParseJson do
  context "with another content-type" do
    before(:each) do
      stub_request(:get, %r{blergh}).to_return(
        :headers => {
          :content_type => "application/xml"
        },
        :body => '<nope></nope>'
      )
    end

    it "should return nil body" do
      client.connection.get("blergh").body.should be_nil
    end
  end

  context "with content-type = 'application/json'" do
    before(:each) do
      stub_request(:get, %r{blergh}).to_return(
        :headers => {
          :content_type => "application/json"
        },
        :body => body
      )
    end

    context "with a nil body" do
      let(:body) { nil }

      it "should return nil body" do
        client.connection.get("blergh").body.should be_nil
      end
    end

    context "with a empty body" do
      let(:body) { '' }

      it "should return nil body" do
        client.connection.get("blergh").body.should be_nil
      end
    end

    context 'proper json' do
      let(:body) { '{ "TESTDATA": true }' }

      it "should parse returned body" do
        client.connection.get("blergh").body['TESTDATA'].should be_true
      end
    end
  end
end

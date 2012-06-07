require 'spec_helper'

describe ZendeskAPI::Middleware::Response::Deflate do
  context "with content-encoding = 'deflate'" do
    subject { '{ "TESTDATA": true }' }

    before(:each) do
      stub_request(:get, %r{blergh}).to_return(:headers => { :content_encoding => "deflate" }, :body => Zlib::Deflate.deflate(subject))
    end

    it "should inflate returned body" do
      client.connection.get("blergh").body['TESTDATA'].should be_true
    end
  end
end

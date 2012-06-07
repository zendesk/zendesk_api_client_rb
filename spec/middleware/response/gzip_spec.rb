require 'spec_helper'

describe ZendeskAPI::Middleware::Response::Gzip do
  context "with content-encoding = 'gzip'" do
    subject { '{ "TESTDATA": true }' }
    before(:each) do
      encoded_data = StringIO.new
      gz = Zlib::GzipWriter.new(encoded_data)
      gz.write(subject)
      gz.close

      stub_request(:get, %r{blergh}).to_return(:headers => { :content_encoding => "gzip" }, :body => encoded_data.string)
    end

    it "should inflate returned body" do
      client.connection.get("blergh").body['TESTDATA'].should be_true
    end
  end
end

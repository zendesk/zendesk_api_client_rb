require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::RaiseError do
  before(:each) do
    stub_request(:any, /.*/).to_return(:status => status)
  end

  context "with status = 404" do
    let(:status) { 404 }

    it "should raise RecordNotFound when status is 404" do
      expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::RecordNotFound)
    end
  end

  context "with status in 400...600" do
    let(:status) { 500 }

    it "should raise NetworkError" do
      expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::NetworkError)
    end
  end

  context "with status = 422" do
    let(:status) { 422 }

    it "should raise RecordInvalid" do
      expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::RecordInvalid)
    end
  end

  context "with status = 200" do
    let(:status) { 200 }

    it "should not raise" do
      client.connection.get "/abcdef"
    end
  end
end


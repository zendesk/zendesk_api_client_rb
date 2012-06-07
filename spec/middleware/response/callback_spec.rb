require 'spec_helper'

describe ZendeskAPI::Middleware::Response::Callback do
  let(:response) { "TEST" }

  before(:each) do
    client.insert_callback do |env|
      env[:body] = response
    end

    stub_request(:get, %r{test_endpoint}).to_return(:body => JSON.dump({ "ABC" => "DEF" }))
  end

  it "should call callbacks " do
    client.connection.get("test_endpoint").body.should == response
  end
end

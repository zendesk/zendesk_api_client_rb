require 'spec_helper'

describe ZendeskAPI::Middleware::Request::EtagCache do
  it "caches" do
    client.config.cache.size = 1

    stub_json_request(:get, %r{blergh}, '{"x":1}', :headers => {"Etag" => "x"})
    response = client.connection.get("blergh")
    response.status.should == 200
    response.body.should == {"x"=>1}

    stub_request(:get, %r{blergh}).to_return(:status => 304, :headers => {"Etag" => "x"})
    response = client.connection.get("blergh")
    response.status.should == 304
    response.body.should == {"x"=>1}
  end
end

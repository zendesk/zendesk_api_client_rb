require 'spec_helper'

describe ZendeskAPI::Middleware::Request::EtagCache do
  def fake_response(data)
    stub_request(:get, %r{blergh}).to_return(:status => 200, :body => data)
    response = client.connection.get("blergh")
    response.status.should == 200
    response
  end

  it "caches" do
    client.config.cache.size = 1

    stub_request(:get, %r{blergh}).to_return(:status => 200, :body => '{"x":1}', :headers => {"Etag" => "x"})
    response = client.connection.get("blergh")
    response.status.should == 200
    response.body.should == {"x"=>1}

    stub_request(:get, %r{blergh}).to_return(:status => 304, :response_headers => {"Etag" => "x"})
    response = client.connection.get("blergh")
    response.status.should == 304
    response.body.should == {"x"=>1}
  end
end

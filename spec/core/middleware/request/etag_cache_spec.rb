require 'core/spec_helper'

describe ZendeskAPI::Middleware::Request::EtagCache do
  it "caches" do
    client.config.cache.size = 1

    stub_json_request(:get, %r{blergh}, '{"x":1}', :headers => {"Etag" => "x"})
    first_response = client.connection.get("blergh")
    first_response.status.should == 200
    first_response.body.should == {"x"=>1}

    stub_request(:get, %r{blergh}).to_return(:status => 304, :headers => {"Etag" => "x"})
    response = client.connection.get("blergh")
    response.status.should == 304
    response.body.should == {"x"=>1}

    %w{content_encoding content_type content_length etag}.each do |header|
      response.headers[header].should == first_response.headers[header]
    end
  end
end

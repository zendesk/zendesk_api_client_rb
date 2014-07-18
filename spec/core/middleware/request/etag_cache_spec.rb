require 'core/spec_helper'

describe ZendeskAPI::Middleware::Request::EtagCache do
  it "caches" do
    client.config.cache.size = 1

    stub_json_request(:get, %r{blergh}, '{"x":1}', :headers => {"Etag" => "x"})
    first_response = client.connection.get("blergh")
    expect(first_response.status).to eq(200)
    expect(first_response.body).to eq({"x"=>1})

    stub_request(:get, %r{blergh}).to_return(:status => 304, :headers => {"Etag" => "x"})
    response = client.connection.get("blergh")
    expect(response.status).to eq(304)
    expect(response.body).to eq({"x"=>1})

    %w{content_encoding content_type content_length etag}.each do |header|
      expect(response.headers[header]).to eq(first_response.headers[header])
    end
  end
end

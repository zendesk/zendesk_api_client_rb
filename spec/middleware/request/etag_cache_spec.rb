require 'spec_helper'

describe "EtagCache" do
  def fake_response(data)
    stub_request(:get, %r{blergh}).to_return(:status => 200, :body => data)
    response = client.connection.get("blergh")
    response.status.should == 200
    response
  end

  before do
    stub_request(:get, %r{blergh}).to_return(:status => 200, :body => '{"x":1}', :headers => {"Cache-Control" => "public, max-age=2592000"})
    response = client.connection.get("blergh")
    response.status.should == 200
    response.body.should == {"x" => 1}
  end

  it "caches" do
    WebMock::StubRegistry.instance.reset! # no connection allowed
    response = client.connection.get("blergh")
    response.status.should == 200
    response.body.should == {"x"=>1}
  end

  it "uses given cache store" do
    client.config.cache.clear
    stub_request(:get, %r{blergh}).to_return(:status => 200, :body => '{"x":2}', :headers => {"Cache-Control" => "public, max-age=2592000"})

    response = client.connection.get("blergh")
    response.status.should == 200
    response.body.should == {"x"=>2}
  end
end

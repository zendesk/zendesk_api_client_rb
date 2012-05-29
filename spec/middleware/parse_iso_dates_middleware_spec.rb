require 'spec_helper'

describe Zendesk::Response::ParseIsoDatesMiddleware, :vcr_off do
  def fake_response(data)
    stub_request(:get, %r{blergh}).to_return(:status => 200, :body => data)
    response = client.connection.get("blergh")
    response.status.should == 200
    response
  end

  let(:parsed){ "2012-02-01 13:14:15 UTC" }

  it "should parse dates" do
    fake_response('{"x":"2012-02-01T13:14:15Z"}').body["x"].to_s.should == parsed
  end

  it "should parse nested dates in hash" do
    fake_response('{"x":{"y":"2012-02-01T13:14:15Z"}}').body["x"]["y"].to_s.should == parsed
  end

  it "should parse nested dates in arrays" do
    fake_response('{"x":[{"y":"2012-02-01T13:14:15Z"}]}').body["x"][0]["y"].to_s.should == parsed
  end

  it "should not blow up on empty body" do
    fake_response('').body.should == nil
  end

  it "should leave arrays with ids alone" do
    fake_response('{"x":[1,2,3]}').body.should == {"x" => [1,2,3]}
  end

  it "should not parse date-like things" do
    fake_response('{"x":"2012-02-01T13:14:15Z bla"}').body["x"].to_s.should == "2012-02-01T13:14:15Z bla"
    fake_response('{"x":"12012-02-01T13:14:15Z"}').body["x"].to_s.should == "12012-02-01T13:14:15Z"
    fake_response(%Q{{"x":"2012-02-01T13:14:15Z\\nfoo"}}).body["x"].to_s.should == "2012-02-01T13:14:15Z\nfoo"
  end
end

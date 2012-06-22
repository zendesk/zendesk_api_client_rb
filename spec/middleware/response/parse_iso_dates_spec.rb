require 'spec_helper'

describe ZendeskAPI::Middleware::Response::ParseIsoDates do
  def fake_response(data)
    stub_json_request(:get, %r{blergh}, data)
    response = client.connection.get("blergh")
    response.status.should == 200
    response
  end

  let(:parsed){
    if RUBY_VERSION > "1.9"
      "2012-02-01 13:14:15 UTC"
    else
      "Wed Feb 01 13:14:15 UTC 2012"
    end
  }

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

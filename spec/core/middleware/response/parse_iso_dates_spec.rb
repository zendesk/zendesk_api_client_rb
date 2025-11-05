require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::ParseIsoDates do
  def fake_response(data)
    stub_json_request(:get, %r{blergh}, data)
    response = client.connection.get("blergh")
    expect(response.status).to eq(200)
    response
  end

  let(:parsed) { "2012-02-01 13:14:15 UTC" }

  it "should parse dates" do
    expect(fake_response('{"x":"2012-02-01T13:14:15Z"}').body["x"].to_s).to eq(parsed)
  end

  it "should parse nested dates in hash" do
    expect(fake_response('{"x":{"y":"2012-02-01T13:14:15Z"}}').body["x"]["y"].to_s).to eq(parsed)
  end

  it "should parse nested dates in arrays" do
    expect(fake_response('{"x":[{"y":"2012-02-01T13:14:15Z"}]}').body["x"][0]["y"].to_s).to eq(parsed)
  end

  it "should not blow up on empty body" do
    expect(fake_response('').body).to eq('')
  end

  it "should leave arrays with ids alone" do
    expect(fake_response('{"x":[1,2,3]}').body).to eq({ "x" => [1, 2, 3] })
  end

  it "should not parse date-like things" do
    expect(fake_response('{"x":"2012-02-01T13:14:15Z bla"}').body["x"].to_s).to eq("2012-02-01T13:14:15Z bla")
    expect(fake_response('{"x":"12012-02-01T13:14:15Z"}').body["x"].to_s).to eq("12012-02-01T13:14:15Z")
    expect(fake_response('{"x":"2012-02-01T13:14:15Z\\nfoo"}').body["x"].to_s).to eq("2012-02-01T13:14:15Z\nfoo")
  end
end

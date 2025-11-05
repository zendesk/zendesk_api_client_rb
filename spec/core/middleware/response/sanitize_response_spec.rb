describe ZendeskAPI::Middleware::Response::SanitizeResponse do
  def fake_response(data)
    stub_json_request(:get, /blergh/, data)
    response = client.connection.get("blergh")
    expect(response.status).to eq(200)
    response
  end

  describe "with bad characters" do
    let(:response) { fake_response("{\"x\":\"2012-02-01T13:14:15Z\", \"y\":\"\u0315\u0316\u01333\u0270\u022712awesome!" + [0xd83d, 0xdc4d].pack("U*") + "\"}") }

    it "removes bad characters" do
      expect(response.body.to_s.valid_encoding?).to be(true)
      expect(response.body["y"].to_s).to eq("\u0315\u0316\u01333\u0270\u022712awesome!")
    end
  end
end

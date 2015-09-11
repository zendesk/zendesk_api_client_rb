require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::SanitizeResponse do
  def fake_response(data)
    stub_json_request(:get, %r{blergh}, data)
    response = client.connection.get('blergh')
    expect(response.status).to eq(200)
    response
  end

  describe 'with bad characters' do
    let(:response) { fake_response("{\"x\":\"2012-02-01T13:14:15Z\", \"y\":\"\u0315\u0316\u01333\u0270\u022712awesome!\ud83d\udc4d\"}") }

    it 'removes bad characters' do
      expect(response.body.to_s.valid_encoding?).to be(true)
      expect(response.body['y'].to_s).to eq("\u0315\u0316\u01333\u0270\u022712awesome!")
    end
  end
end

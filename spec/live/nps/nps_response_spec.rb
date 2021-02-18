require 'core/spec_helper'

describe ZendeskAPI::Nps::Response do

  describe ".incremental_export" do
    let(:results) { ZendeskAPI::Nps::Response.incremental_export(client, Time.at(1023059503)) } # ~ 10 years ago

    around do |example|
      # 1 request every 5 minutes allowed <-> you can only test 1 call ...
      VCR.use_cassette("responses_incremental_export") do
        client.config.retry = false

        example.call

        client.config.retry = true
      end
    end

    it "finds nps_responses after a old date" do
      expect(results.to_a.first).to be_an_instance_of ZendeskAPI::Nps::Response
    end

    it "is able to do next" do
      first = results.to_a.first
      stub_json_request(:get, %r{/api/v2/nps/incremental/responses}, json(:results => []))

      results.next
      expect(results.first).to_not eq(first)
    end
  end
end

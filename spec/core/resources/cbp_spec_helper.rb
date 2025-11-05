shared_examples "an endpoint that supports CBP" do
  let(:collection_fetched) do
    VCR.use_cassette("cbp_#{described_class}_collection_fetch") do
      collection.fetch
      collection
    end
  end

  let(:response_body) { collection_fetched.response.body }
  let(:collection_fetched_results) { collection_fetched.to_a }

  it "returns a CBP response with all the correct keys" do
    expect(response_body).to have_key("meta")
    expect(response_body).to have_key("links")
    expect(response_body["meta"].keys).to match_array(%w[has_more after_cursor before_cursor])
    expect(response_body["links"].keys).to match_array(%w[prev next])
  end

  it "returns a list of #{described_class} objects" do
    expect(collection_fetched_results).to all(be_a(described_class))
  end
end

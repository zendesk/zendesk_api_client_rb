def expect_cbp_response_for(collection)
  context collection.path.to_s, :vcr do
    before do
      @resource_klass = collection.instance_variable_get(:@resource_class)
      VCR.use_cassette("cbp_#{@resource_class}_#{collection.path}") do
        @result = collection.fetch
        @response_body = collection.response.body
      end
    end
    it 'expects an array with the correct element types' do
      expect(@result).to all(be_a(@resource_klass))
    end

    it 'expects a CBP response with all the correct keys' do
      expect(@response_body).to have_key('meta')
      expect(@response_body).to have_key('links')
      expect(@response_body['meta'].keys).to match_array(%w[has_more after_cursor before_cursor])
      expect(@response_body['links'].keys).to match_array(%w[prev next])
    end
  end
end

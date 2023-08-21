require 'core/spec_helper'

RSpec.describe ZendeskAPI::Data do
  describe ".new_from_response" do
    let(:response) { double(:response) }

    it "returns an instance with the response" do
      expect(described_class.new_from_response(client, response))
        .to be_instance_of(described_class)
    end
  end
end

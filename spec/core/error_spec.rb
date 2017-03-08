require 'core/spec_helper'

describe ZendeskAPI::Error do
  describe ZendeskAPI::Error::ClientError do
    it "works without a response" do
      expect(ZendeskAPI::Error::ClientError.new("foo").message).to eq "foo"
    end
  end
end

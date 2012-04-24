require 'spec/spec_helper'

describe Zendesk::ReadResource do
  let(:client) { valid_client }

  context "find", :vcr_off do
    let(:id) { 1 }
    subject { Zendesk::TestResource }

    before(:each) do
      stub_request(:get, %r{test_resources/#{id}}).to_return({})
    end

    it "should return instance of resource" do
      subject.find(client, id).should be_instance_of(subject)
    end

    context "with client error" do
      before(:each) do
        stub_request(:get, %r{test_resources/#{id}}).to_return(:status => 500)
      end

      it "should handle it properly" do
        expect { subject.find(client, id).should be_nil }.to_not raise_error
      end
    end
  end
end


require 'spec/spec_helper'

describe Zendesk::CreateResource do
  let(:client) { valid_client }

  context "create", :vcr_off do
    let(:attr) { { :test_field => "blah" } }
    subject { Zendesk::TestResource }

    before(:each) do
      stub_request(:post, %r{test_resources}).to_return({})
    end

    it "should return instance of resource" do
      subject.create(client, attr).should be_instance_of(subject) 
    end

    context "with client error" do
      before(:each) do
        stub_request(:post, %r{test_resources}).to_return(:status => 500)
      end

      it "should handle it properly" do
        expect { subject.create(client, attr).should be_nil }.to_not raise_error
      end
    end
  end
end


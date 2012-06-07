require 'spec_helper'

describe ZendeskAPI::ReadResource do
  context "find" do
    let(:id) { 1 }
    subject { ZendeskAPI::TestResource }

    before(:each) do
      stub_request(:get, %r{test_resources/#{id}}).to_return(:body => json)
    end

    it "should return instance of resource" do
      subject.find(client, :id => id).should be_instance_of(subject)
    end

    context "with client error" do
      before(:each) do
        stub_request(:get, %r{test_resources/#{id}}).to_return(:status => 500)
      end

      it "should handle it properly" do
        expect { silence_stderr { subject.find(client, :id => id).should be_nil } }.to_not raise_error
      end
    end
  end
end


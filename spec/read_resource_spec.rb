require 'spec_helper'

describe ZendeskAPI::ReadResource do
  context "find" do
    let(:id) { 1 }
    subject { ZendeskAPI::TestResource }

    before(:each) do
      stub_json_request(:get, %r{test_resources/#{id}}, json("test_resource" => {}))
    end

    it "should return instance of resource" do
      subject.find(client, :id => id).should be_instance_of(subject)
    end

    it "should blow up without an id which would build an invalid url" do
      expect{
        ZendeskAPI::User.find(client, :foo => :bar)
      }.to raise_error("No :id given")
    end

    context "with client error" do
      it "should handle 500 properly" do
        stub_request(:get, %r{test_resources/#{id}}).to_return(:status => 500)
        client.config.logger.should_receive(:warn).at_least(:once)
        subject.find(client, :id => id).should == nil
      end

      it "should handle 404 properly" do
        stub_request(:get, %r{test_resources/#{id}}).to_return(:status => 404)
        client.config.logger.should_receive(:warn).at_least(:once)
        subject.find(client, :id => id).should == nil
      end
    end
  end
end


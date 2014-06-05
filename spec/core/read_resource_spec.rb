require 'core/spec_helper'

describe ZendeskAPI::ReadResource do
  context "find" do
    let(:id) { 1 }
    subject { ZendeskAPI::TestResource }

    context "normal request" do
      before(:each) do
        stub_json_request(:get, %r{test_resources/#{id}}, json("test_resource" => {}))
      end

      it "should return instance of resource" do
        subject.find(client, :id => id).should be_instance_of(subject)
      end
    end

    it "should blow up without an id which would build an invalid url" do
      expect{
        ZendeskAPI::User.find(client, :foo => :bar)
      }.to raise_error("No :id given")
    end

    context "with overriden handle_response" do
      subject do
        Class.new(ZendeskAPI::TestResource) do
          def self.singular_resource_name
            'hello'
          end

          def handle_response(response)
            @attributes.replace(response.body)
          end
        end
      end

      before(:each) do
        stub_json_request(:get, %r{hellos/#{id}}, json(:testing => 1))
      end

      it "should return instance of resource" do
        object = subject.find(client, :id => id)
        object.should be_instance_of(subject)
        object.testing.should == 1
      end
    end

    context "with side loads" do
      before(:each) do
        stub_json_request(:get, %r{test_resources/#{id}\?include=nil_resource}, json(
          "test_resource" => { :id => 1, :nil_resource_id => 2 },
          "nil_resources" => [{ :id => 1, :name => :bye }, { :id => 2, :name => :hi }]
        ))

        subject.has ZendeskAPI::NilResource
        @resource = subject.find(client, :id => id, :include => :nil_resource)
      end

      it "should side load nil resource" do
        @resource.nil_resource.name.should == "hi"
      end
    end

    context "with client error" do
      it "should handle 500 properly" do
        stub_request(:get, %r{test_resources/#{id}}).to_return(:status => 500)
        subject.find(client, :id => id).should == nil
      end

      it "should handle 404 properly" do
        stub_request(:get, %r{test_resources/#{id}}).to_return(:status => 404)
        subject.find(client, :id => id).should == nil
      end
    end
  end
end


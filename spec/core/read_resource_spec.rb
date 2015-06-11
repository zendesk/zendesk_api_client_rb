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
        expect(subject.find(client, :id => id)).to be_instance_of(subject)
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
        expect(object).to be_instance_of(subject)
        expect(object.testing).to eq(1)
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
        expect(@resource.nil_resource.name).to eq("hi")
      end
    end

    context "with client error" do
      it "should handle 500 properly" do
        stub_request(:get, %r{test_resources/#{id}}).to_return(:status => 500)
        expect(subject.find(client, :id => id)).to eq(nil)
      end

      it "should handle 404 properly" do
        stub_request(:get, %r{test_resources/#{id}}).to_return(:status => 404)
        expect(subject.find(client, :id => id)).to eq(nil)
      end
    end
  end

  context "#reload!" do
    let(:id) { 2 }

    subject { ZendeskAPI::TestResource.new(client, :id => id, :name => 'Old Name') }

    before(:each) do
      stub_json_request(:get, %r{test_resources/#{id}}, json("test_resource" => {:id => id, :name => "New Name" }))
    end

    it "reloads the data" do
      expect(subject.name).to eq('Old Name')
      assert_not_requested(:get, %r{test_resources/#{id}})

      subject.reload!

      assert_requested(:get, %r{test_resources/#{id}})
      expect(subject.name).to eq('New Name')
    end
  end
end


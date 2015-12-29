require 'core/spec_helper'
require 'zendesk_api/association'

describe ZendeskAPI::Association do
  let(:instance) { ZendeskAPI::TestResource.new(client, :id => 1) }
  let(:child) { ZendeskAPI::TestResource::TestChild.new(client, :id => 1, :test_resource_id => 2) }

  describe "setting/getting" do
    context "has" do
      before do
        ZendeskAPI::TestResource.associations.clear
        ZendeskAPI::TestResource.has :child, class: ZendeskAPI::TestResource::TestChild, path: 'test_resources/%{id}/child/%{child_id}'
      end

      it "should not try and fetch nil child" do
        instance.child_id = nil
        expect(instance.child).to be_nil
      end

      it "should cache an set object" do
        instance.child = child
        expect(instance.child).to eq(child)
      end

      it "should set id on set if it was there" do
        instance.child_id = nil
        instance.child = child
        expect(instance.child_id).to eq(child.id)
      end

      it "should build a object set via hash" do
        instance.child = {:id => 2}
        expect(instance.child.id).to eq(2)
      end

      it "should build a object set via id" do
        instance.child = 2
        expect(instance.child.id).to eq(2)
      end

      it "should not fetch an unknown object" do
       expect(instance.child).to be_nil
      end

      it "should fetch an object known by id" do
        stub_json_request(:get, %r{test_resources/1/child/5}, json(:test_child => {:id => 5}))
        instance.child_id = 5
        expect(instance.child.id).to eq(5)
      end

      xit "should handle client errors" do
        stub_request(:get, %r{test_resources/1/child/5}).to_return(:status => 500)
        instance.child_id = 5
        expect { silence_logger { instance.child } }.to_not raise_error
      end

      xit "should handle resource not found errors" do
        stub_request(:get, %r{test_resources/1/child/5}).to_return(:status => 404)
        instance.child_id = 5
        silence_logger{ expect(instance.child).to be_nil }
      end

      it "is not used when not used" do
        expect(instance.child_used?).to eq(false)
      end

      it "is used when used" do
        instance.child = child
        expect(instance.child_used?).to eq(true)
      end
    end

    context "has_many" do
      it "should cache a set object" do
        instance.children = [child]
        expect(instance.children.map(&:id)).to eq([1])
        expect(instance.children).to be_instance_of(ZendeskAPI::Collection)
      end

      it "should set ids" do
        instance.children_ids = []
        instance.children = [child]
        expect(instance.children_ids).to eq([child.id])
        expect(instance.children).to be_instance_of(ZendeskAPI::Collection)
      end

      it "should build and cache objects set via hash" do
        instance.children = [{:id => 2}]
        expect(instance.children.map(&:id)).to eq([2])
        expect(instance.children).to be_instance_of(ZendeskAPI::Collection)
      end

      it "should build a object set via id" do
        instance.children = [2]
        expect(instance.children.map(&:id)).to eq([2])
        expect(instance.children).to be_instance_of(ZendeskAPI::Collection)
      end

      it "should fetch unknown objects" do
        stub_json_request(:get, %r{test_resources/1/children}, json(:test_children => [{:id => 2}, {:id => 3}]))
        expect(instance.children.map(&:id)).to eq([2,3])
        expect(instance.children).to be_instance_of(ZendeskAPI::Collection)
      end

      it "should not change objects" do
        child = 'foo'
        children = [child]
        instance.children = children
        expect(children[0]).to eq('foo')
      end

      it "is not used when not used" do
        expect(instance.children_used?).to eq(false)
      end

      it "is used when used" do
        instance.children = [child]
        expect(instance.children_used?).to eq(true)
      end
    end
  end
end

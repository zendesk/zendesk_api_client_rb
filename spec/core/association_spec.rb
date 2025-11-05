require "core/spec_helper"

describe ZendeskAPI::Association do
  let(:instance) { ZendeskAPI::TestResource.new(client, :id => 1) }
  let(:child) { ZendeskAPI::TestResource::TestChild.new(client, :id => 1, :test_resource_id => 2) }

  describe "setting/getting" do
    context "has" do
      before do
        ZendeskAPI::TestResource.associations.clear
        ZendeskAPI::TestResource.has :child, :class => ZendeskAPI::TestResource::TestChild
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

      it "should handle client errors" do
        stub_request(:get, %r{test_resources/1/child/5}).to_return(:status => 500)
        instance.child_id = 5
        expect { silence_logger { instance.child } }.to_not raise_error
      end

      it "should handle resource not found errors" do
        stub_request(:get, %r{test_resources/1/child/5}).to_return(:status => 404)
        instance.child_id = 5
        silence_logger { expect(instance.child).to be_nil }
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
        expect(instance.children.map(&:id)).to eq([2, 3])
        expect(instance.children).to be_instance_of(ZendeskAPI::Collection)
      end

      it "should not change objects" do
        child = "foo"
        children = [child]
        instance.children = children
        expect(children[0]).to eq("foo")
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

  context "class only" do
    subject { described_class.new(:class => ZendeskAPI::TestResource) }

    it "should generate resource path" do
      expect(subject.generate_path).to eq("test_resources")
    end

    context "with an instance" do
      it "should generate a specific resource path" do
        expect(subject.generate_path(instance)).to eq("test_resources/1")
      end

      context "with_id => false" do
        it "should generate general resource path" do
          expect(subject.generate_path(instance, :with_id => false)).to eq("test_resources")
        end
      end

      context "with an instance that is a new record" do
        it "should generate general resource path" do
          expect(subject.generate_path(ZendeskAPI::TestResource.new(client))).to eq("test_resources")
        end
      end
    end

    context "with a specified path" do
      before(:each) { subject.options[:path] = "blergh" }

      it "should generate general resource path" do
        expect(subject.generate_path).to eq("blergh")
      end
    end

    context "with a passed in id" do
      it "should generate specific resource path" do
        opts = {:id => 1}
        expect(subject.generate_path(opts)).to eq("test_resources/1")
        expect(opts).to be_empty
      end
    end
  end

  context "class with a specified parent" do
    subject { described_class.new(:class => ZendeskAPI::TestResource::TestChild, :parent => instance, :name => :children) }

    it "should generate nested resource path" do
      expect(subject.generate_path).to eq("test_resources/1/children")
    end

    context "with an instance" do
      it "should generate a specific nested resource path" do
        expect(subject.generate_path(child)).to eq("test_resources/1/children/1")
      end

      context "with_id => false" do
        it "should generate nested resource path" do
          expect(subject.generate_path(child, :with_id => false)).to eq("test_resources/1/children")
        end
      end
    end

    context "when parent has a namespace" do
      before(:each) do
        instance.class.namespace "hello"
      end

      after(:each) do
        instance.class.namespace nil
      end

      it "should generate a specific nested resource path" do
        expect(subject.generate_path(child)).to eq("hello/test_resources/1/children/1")
      end
    end

    context "with a specified path" do
      before(:each) { subject.options[:path] = "blergh" }

      it "should generate nested resource path" do
        expect(subject.generate_path).to eq("test_resources/1/blergh")
      end
    end

    context "with a path on the association" do
      before(:each) do
        association = ZendeskAPI::TestResource.associations.detect { |a| a[:name] == :children }
        association[:path] = "blergh"
      end

      it "should generate nested resource path" do
        expect(subject.generate_path).to eq("test_resources/1/blergh")
      end
    end

    context "with no association" do
      before(:each) do
        ZendeskAPI::TestResource.associations.clear
      end

      it "should generate nested resource path" do
        expect(subject.generate_path).to eq("test_resources/1/test_children")
      end
    end
  end

  context "class with a parent id" do
    subject { described_class.new(:class => ZendeskAPI::TestResource::TestChild, :name => :children) }

    it "should raise an error if not passed an instance or id" do
      expect { subject.generate_path }.to raise_error(ArgumentError)
    end

    it "should generate specific nested resource path" do
      expect(subject.generate_path(child)).to eq("test_resources/2/children/1")
    end

    context "with parent id passed in" do
      it "should generate nested resource path" do
        opts = {:test_resource_id => 3}
        expect(subject.generate_path(opts)).to eq("test_resources/3/children")
        expect(opts).to be_empty
      end
    end
  end

  context "with a singular resource" do
    subject { described_class.new(:class => ZendeskAPI::SingularTestResource) }

    context "with an instance" do
      it "should not generate a specific resource path" do
        expect(subject.generate_path(ZendeskAPI::SingularTestResource.new(client, :id => 1))).to eq("singular_test_resources")
      end
    end
  end
end

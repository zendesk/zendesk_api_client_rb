require 'spec_helper'

describe Zendesk::Association do
  let(:instance) { Zendesk::TestResource.new(client, :id => 1) }
  let(:child) { Zendesk::TestResource::TestChild.new(client, :id => 1, :test_resource_id => 2) }

  describe "setting/getting", :vcr_off do
    context "has" do
      before do
        Zendesk::TestResource.associations.clear
        Zendesk::TestResource.has :child, :class => :test_child
      end

      it "should cache an set object" do
        instance.child = child
        instance.child.should == child
      end

      it "should set id on set if it was there" do
        instance.child_id = nil
        instance.child = child
        instance.child_id.should == child.id
      end

      it "should not set id on set if it was not there" do
        instance.child = child
        instance.child_id.should == nil
      end

      it "should build a object set via hash" do
        instance.child = {:id => 2}
        instance.child.id.should == 2
      end

      it "should build a object set via id" do
        instance.child = 2
        instance.child.id.should == 2
      end

      it "should fetch a unknown object" do
        stub_request(:get, %r{test_resources/1/child}).to_return(:body => {"test_child" => {"id" => 2}})
        instance.child.id.should == 2
      end

      it "should fetch an object known by id" do
        stub_request(:get, %r{test_resources/1/child/5}).to_return(:body => {"test_child" => {"id" => 5}})
        instance.child_id = 5
        instance.child.id.should == 5
      end
    end

    context "has_many" do
      it "should cache a set object" do
        instance.children = [child]
        instance.children.map(&:id).should == [1]
      end

      it "should build and cache objects set via hash" do
        instance.children = [{:id => 2}]
        instance.children.map(&:id).should == [2]
      end

      it "should build a object set via id" do
        instance.children = [2]
        instance.children.map(&:id).should == [2]
      end

      it "should fetch unknown objects" do
        stub_request(:get, %r{test_resources/1/children}).to_return(:body => {"test_children" => [{"id" => 2}, {"id" => 3}]})
        instance.children.map(&:id).should == [2,3]
      end
    end
  end

  context "class only" do
    subject { described_class.new(:class => Zendesk::TestResource) }

    it "should generate resource path" do
      subject.generate_path.should == "test_resources"
    end

    context "with an instance" do
      it "should generate a specific resource path" do
        subject.generate_path(instance).should == "test_resources/1"
      end

      context "with_id => false" do
        it "should generate general resource path" do
          subject.generate_path(instance, :with_id => false).should == "test_resources"
        end
      end

      context "with an instance that is a new record" do
        it "should generate general resource path" do
          subject.generate_path(Zendesk::TestResource.new(client)).should == "test_resources"
        end
      end
    end

    context "with a specified path" do
      before(:each) { subject.options[:path] = "blergh" }

      it "should generate general resource path" do
        subject.generate_path.should == "blergh"
      end
    end

    context "with a passed in id" do
      it "should generate specific resource path" do
        opts = { :id => 1 }
        subject.generate_path(opts).should == "test_resources/1"
        opts.should be_empty
      end
    end
  end

  context "class with a specified parent" do
    subject { described_class.new(:class => Zendesk::TestResource::TestChild, :parent => instance) }

    it "should generate nested resource path" do
      subject.generate_path.should == "test_resources/1/children"
    end

    context "with an instance" do
      it "should generate a specific nested resource path" do
        subject.generate_path(child).should == "test_resources/1/children/1"
      end

      context "with_id => false" do
        it "should generate nested resource path" do
          subject.generate_path(child, :with_id => false).should == "test_resources/1/children"
        end
      end
    end

    context "with a specified path" do
      before(:each) { subject.options[:path] = "blergh" }

      it "should generate nested resource path" do
        subject.generate_path.should == "test_resources/1/blergh"
      end
    end
  end

  context "class with a parent id" do
    subject { described_class.new(:class => Zendesk::TestResource::TestChild) }

    it "should raise an error if not passed an instance or id" do
      expect { subject.generate_path }.to raise_error(ArgumentError)
    end

    it "should generate specific nested resource path" do
      subject.generate_path(child).should == "test_resources/2/children/1"
    end

    context "with parent id passed in" do
      it "should generate nested resource path" do
        opts = { :test_resource_id => 3 }
        subject.generate_path(opts).should == "test_resources/3/children"
        opts.should be_empty
      end
    end
  end

  context "with a signular resource" do
    subject { described_class.new(:class => Zendesk::SingularTestResource) }

    context "with an instance" do
      it "should not generate a specific resource path" do
        subject.generate_path(Zendesk::SingularTestResource.new(client, :id => 1)).should == "singular_test_resources"
      end
    end
  end
end

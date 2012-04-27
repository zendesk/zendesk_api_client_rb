require 'spec_helper'

describe Zendesk::DataResource do
  context "Zendesk.get_class" do
    it "should create a new class if there is none" do
      Zendesk.const_defined?("Blergh").should be_false
      Zendesk.get_class(:blergh).should == Zendesk::Blergh
    end

    it "should find the class if it exists" do
      Zendesk.get_class(:tickets).should == Zendesk::Tickets
    end

    it "should handle 'nil' be passed in" do
      Zendesk.get_class(nil).should be_false
    end
  end

  specify "singular resource name" do
    Zendesk::Ticket.singular_resource_name.should == "ticket"
    Zendesk::TicketField.singular_resource_name.should == "ticket_field"
  end

  specify "resource name" do
    Zendesk::Ticket.resource_name.should == "tickets"
    Zendesk::TicketField.resource_name.should == "ticket_fields"
    Zendesk::Category.resource_name.should == "categories"
  end

  context "user" do 
    context "with first order attributes" do
      subject { Zendesk::TestResource.new(client) }
      before(:each) { subject.attributes[:priority] = "normal" }

      it "should be able to access underlying attributes" do
        subject.priority.should == "normal"
      end

      it "should be able to change underlying attributes" do
        expect { subject.priority = "urgent" }.to_not raise_error
      end

      it "should be able to iterate over underlying attributes" do
        expect do
          subject.map do |k, v|
            [k.to_sym, v]
          end
        end.to_not raise_error
      end
    end

    context "with second order attributes" do
      subject { Zendesk::TestResource.new(client) }
      before(:each) { subject.attributes[:test_resource] = { :priority => "normal" } }

      it "should be able to change underlying attributes" do
        subject.priority.should == "normal"
      end

      it "should be able to change underlying attributes" do
        expect { subject.priority = "urgent" }.to_not raise_error
      end

      it "should be able to iterate over underlying attributes" do
        expect do
          subject.map do |k, v|
            [k.to_sym, v]
          end
        end.to_not raise_error
      end
    end
  end

  context "has" do
    before(:each) { Zendesk::TestResource.has :foo }

    context "class methods" do
      subject { Zendesk::TestResource }
      it "should define a method with the same name" do
        subject.instance_methods.map(&:to_s).should include("foo")
      end

      it "should create a class if none exists" do
        Zendesk.const_defined?("Foo").should be_true
      end

      context "with explicit class name" do
        before(:all) { Zendesk::TestResource.has :baz, :class => :foo }

        it "should not create a baz class" do
          Zendesk.const_defined?("Baz").should be_false
        end
      end
    end

    context "instance method" do
      context "with no side-loading", :vcr_off do
        subject { Zendesk::TestResource.new(client, :id => 1) }
        before(:each) { stub_request(:get, %r{test_resources/[0-9]+/foo}).to_return({}) }

        it "should attempt to grab the resource from the host" do
          subject.foo.should be_instance_of(Zendesk::Foo)
        end

        it "should pass the path on to the resource" do
          subject.foo.path.should == "foos"
        end

        context "with a client error" do
          before(:each) { stub_request(:get, %r{test_resources/[0-9]+/foo}).to_return(:status => 500) }

          it "should handle it properly" do
            expect { subject.foo.should be_nil }.to_not raise_error
          end
        end
        
        context "with an explicit path set" do
          before(:each) do
            Zendesk::TestResource.has :foo, :path => "blergh"
            stub_request(:get, %r{test_resources/[0-9]+/blergh}).to_return({})
          end

          it "should call the right path" do
            subject.foo.should be_instance_of(Zendesk::Foo)
          end
        end
      end

      context "with side-loading of resource" do
        let(:foo) { { :message => "FOO_OBJ" } }
        subject { Zendesk::TestResource.new(client, :foo => foo) }

        it "should load foo from the hash" do
          subject.foo.should be_instance_of(Zendesk::Foo)
        end
      end

      context "with side-loading of id" do
        let(:foo) { 1 }
        subject { Zendesk::TestResource.new(client, :foo_id => foo) }

        it "should find foo_id and load it from the api" do
          Zendesk::Foo.should_receive(:find).with(client, foo)
          subject.foo
        end

        it "should handle nil response from find api" do
          Zendesk::Foo.should_receive(:find).with(client, foo).twice.and_return(nil)
          subject.foo.should be_nil
          subject.foo
        end
      end
    end
  end

  context "has_many" do
    before(:each) { Zendesk::TestResource.has_many :bars }

    context "class methods" do
      subject { Zendesk::TestResource }
      it "should define a method with the same name" do
        subject.instance_methods.map(&:to_s).should include("bars")
      end

      it "should create a class if none exists" do
        Zendesk.const_defined?("Bar").should be_true
      end

      context "with explicit class name" do
        before(:each) { Zendesk::TestResource.has_many :cats, :class => :foo }

        it "should not create a baz class" do
          Zendesk.const_defined?("Cat").should be_false
        end
      end
    end

    context "instance method" do
      context "with no side-loading", :vcr_off do
        subject { Zendesk::TestResource.new(client, :id => 1) }

        it "should not attempt to grab the resource from the host" do
          subject.bars.should be_instance_of(Zendesk::Collection)
        end

        #it "should pass the path on to the resource" do
        #  subject.bars.path.should == "bars"
        #end

        #context "with an explicit path set" do
        #  before(:each) do
        #    Zendesk::TestResource.has_many :bars, :path => "blargh"
        #  end

        #  it "should call the right path" do
        #    subject.bars.path.should == "test_resources/1/blargh"
        #  end
        #end

        #context "with set_path option set to true" do
        #  before(:each) do
        #    Zendesk::TestResource.has_many :bars, :set_path => true 
        #  end

        #  it "should call the right path" do
        #    subject.bars.path.should == "test_resources/1/bars"
        #  end
        #end
      end

      context "with side-loading of resource" do
        let(:bars) { [{ :message => "FOO_OBJ" }] }
        subject { Zendesk::TestResource.new(client, :bars => bars) }

        it "should map bars onto Bar class" do
          subject.bars.first.should be_instance_of(Zendesk::Bar)
        end
      end

      context "with side-loading of id" do
        let(:bars) { [1, 2, 3] }
        subject { Zendesk::TestResource.new(client, :bar_ids => bars) }

        it "should find foo_id and load it from the api" do
          Zendesk::Bar.should_receive(:find).with(client, kind_of(Numeric)).exactly(bars.length).times
          subject.bars
        end

        it "should handle nil response from find api" do
          Zendesk::Bar.should_receive(:find).with(client, kind_of(Numeric)).exactly(bars.length).times.and_return(nil)
          subject.bars.should be_empty
          subject.bars # Test expectations
        end
      end
    end
  end
end


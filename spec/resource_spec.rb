require 'spec_helper'

describe ZendeskAPI::Resource do
  context "#update" do
    context "class method" do
      let(:id) { 1 }
      subject { ZendeskAPI::TestResource }

      before(:each) do
        stub_json_request(:put, %r{test_resources/#{id}})
      end

      it "should return instance of resource" do
        subject.update(client, :id => id).should be_true
      end

      context "with client error" do
        before(:each) do
          stub_request(:put, %r{test_resources/#{id}}).to_return(:status => 500)
        end

        it "should handle it properly" do
          expect { silence_logger{ subject.update(client, :id => id).should be_false } }.to_not raise_error
        end
      end
    end
  end

  context "#destroy" do
    context "class method" do
      let(:id) { 1 }
      subject { ZendeskAPI::TestResource }

      before(:each) do
        stub_json_request(:delete, %r{test_resources/#{id}})
      end

      it "should return instance of resource" do
        subject.destroy(client, :id => id).should be_true
      end

      context "with client error" do
        before(:each) do
          stub_request(:delete, %r{test_resources/#{id}}).to_return(:status => 500)
        end

        it "should handle it properly" do
          expect { silence_logger{ subject.destroy(client, :id => id).should be_false } }.to_not raise_error
        end
      end
    end

    context "instance method" do
      subject { ZendeskAPI::TestResource.new(client, :id => 1) }

      before(:each) do
        stub_request(:delete, %r{test_resources}).to_return(:status => 200)
      end

      it "should return true and set destroyed" do
        subject.destroy.should be_true
        subject.destroyed?.should be_true
        subject.destroy.should be_false
      end

      context "with client error" do
        before(:each) do
          stub_request(:delete, %r{test_resources}).to_return(:status => 500)
        end

        it "should return false and not set destroyed" do
          silence_logger{ subject.destroy.should be_false }
          subject.destroyed?.should be_false
        end
      end
    end
  end

  context "#save!" do
    subject { ZendeskAPI::TestResource.new(client, :id => 1) }

    before(:each) do
      subject.should_receive(:save).and_return(false)
    end

    it "should raise if save fails" do
      expect { subject.save! }.to raise_error
    end
  end

  context "#save" do
    let(:id) { 1 }
    let(:attr) { { :param => "test" } }
    subject { ZendeskAPI::TestResource.new(client, attr.merge(:id => id)) }

    before :each do
      stub_json_request(:put, %r{test_resources/#{id}}, json(:test_resource => { :param => "abc" }))
    end

    it "should not save if already destroyed" do
      subject.should_receive(:destroyed?).and_return(true)
      subject.save.should be_false
    end

    it "should not be a new record with an id" do
      subject.new_record?.should be_false
    end

    it "should put on save" do
      subject.save.should be_true
      subject[:param].should == "abc"
    end

    context "with unused associations" do
      before do
        ZendeskAPI::TestResource.associations.clear
        ZendeskAPI::TestResource.has :child, :class => :test_child
        ZendeskAPI::TestResource.has_many :children, :class => :test_child
      end

      it "should not touch them" do
        subject.save.should == true
      end
    end

    context "with client error" do
      before :each do
        stub_request(:put, %r{test_resources/1}).to_return(:status => 500)
      end

      it "should be properly handled" do
        expect { silence_logger { subject.save.should be_false } }.to_not raise_error
      end
    end

    context "new record" do
      subject { ZendeskAPI::TestResource.new(client, attr) }

      before :each do
        stub_json_request(:post, %r{test_resources}, json(:test_resource => attr.merge(:id => id)), :status => 201)
      end

      it "should be true without an id" do
        subject.new_record?.should be_true
      end

      it "should be false after creating" do
        subject.save.should be_true
        subject.new_record?.should be_false
        subject.id.should == id
      end
    end

    context "with nested associations to save" do
      context "has" do
        before(:each) do
          ZendeskAPI::TestResource.associations.clear
          ZendeskAPI::TestResource.has :child, :class => :test_child
          stub_json_request(:put, %r{test_resources})
          subject.child = { :id => 2 }
        end

        it "should call save on the association" do
          subject.child.foo = "bar"
          subject.child.should_receive(:save)
          subject.save
        end

        it "should not call save on the association if they are synced" do
          subject.child.should_not_receive(:save)
          subject.save
        end
      end

      context "has_many" do
        before(:each) do
          ZendeskAPI::TestResource.associations.clear
          ZendeskAPI::TestResource.has_many :children, :class => :test_child

          stub_json_request(:put, %r{test_resources})
          stub_json_request(:get, %r{children}, json(:test_children => []))
        end

        it "should reset children_ids on save" do
          subject.children = [2, 3]
          subject.children_ids = [1]
          subject.save
          subject.children_ids.should == [2,3]
        end

        it "should not save the associated objects when there are no changes" do
          subject.children = [2]
          subject.children.first.should_not_receive(:save)
          subject.save
        end

        it "should save the associated objects when it is new" do
          subject.children = [{:foo => "bar"}]
          subject.children.first.should_receive(:save)
          subject.save
        end

        it "should not save the associated objects when it is set via full hash" do
          subject.children = [{:id => 1, :foo => "bar"}]
          subject.children.first.should_not_receive(:save)
          subject.save
        end

        it "should save the associated objects when it is changes" do
          subject.children = [{:id => 1}]
          subject.children.first.foo = "bar"
          subject.children.first.should_receive(:save)
          subject.save
        end
      end

      context "inline" do
        before(:each) do
          class ZendeskAPI::NilResource
            def to_param; "TESTDATA"; end
          end

          ZendeskAPI::TestResource.associations.clear
          ZendeskAPI::TestResource.has :nil, :class => :nil_resource, :inline => true

          subject.nil = { :abc => :def }
          subject.save_associations
        end

        it "should save param data" do
          subject.attributes[:nil].should == "TESTDATA"
        end
      end
    end
  end

  %w{put post delete}.each do |verb|
    context "on #{verb}" do
      let(:method) { "test_#{verb}_method" }
      before(:each) do
        ZendeskAPI::TestResource.send(verb, method)
      end

      context "class method" do
        subject { ZendeskAPI::TestResource }

        it "should create a method of the same name" do
          subject.instance_methods.map(&:to_s).should include(method)
        end
      end

      context "instance method" do
        subject { ZendeskAPI::TestResource.new(client, :id => 1) }

        before(:each) do
          stub_json_request(verb.to_sym, %r{test_resources/1/#{method}}, json(:test_resources => [{ :id => 1, :method => method }]))
        end

        it "should return true" do
          subject.send(method).should be_true
        end

        it "should update the attributes if they exist" do
          subject.send(method)
          subject[:method].should == method
        end

        context "with client error" do
          before(:each) do
            stub_request(verb.to_sym, %r{test_resources/1/#{method}}).to_return(:status => 500)
          end

          it "should return false" do
            expect { silence_logger{ subject.send(method).should be_false } }.to_not raise_error
          end
        end
      end
    end
  end

  context "#inspect" do
    it "should display nicely" do
      ZendeskAPI::User.new(client, :foo => :bar).inspect.should == "#<ZendeskAPI::User {\"foo\"=>:bar}>"
    end
  end

  context "#==" do
    it "is same when id is same" do
      ZendeskAPI::TestResource.new(client, :id => 1, "bar" => "baz").should == ZendeskAPI::TestResource.new(client, :id => 1, "foo" => "bar")
    end

    it "is same when object_id is same" do
      object = ZendeskAPI::TestResource.new(client, "bar" => "baz")
      object.should == object
    end

    it "is different when both have no id" do
      ZendeskAPI::TestResource.new(client).should_not == ZendeskAPI::TestResource.new(client)
    end

    it "is different when id is different" do
      ZendeskAPI::TestResource.new(client, :id => 2).should_not == ZendeskAPI::TestResource.new(client, :id => 1)
    end

    it "is different when class is different" do
      ZendeskAPI::TestResource.new(client, :id => 2).should_not == ZendeskAPI::TestResource::TestChild.new(client, :id => 2)
    end

    it "is different when other is no resource" do
      ZendeskAPI::TestResource.new(client, :id => 2).should_not == nil
    end

    it "warns about weird comparissons" do
      object = ZendeskAPI::TestResource.new(client, :id => 2)
      object.should_receive(:warn)
      object.should_not == "xxx"
    end
  end

  context "#new" do
    it "builds with hash" do
      object = ZendeskAPI::TestResource.new(client, {})
      object.attributes.should == {}
    end

    it "fails to build with nil (e.g. empty response from server)" do
      expect{
        ZendeskAPI::TestResource.new(client, nil)
      }.to raise_error(/Expected a Hash/i)
    end
  end
end

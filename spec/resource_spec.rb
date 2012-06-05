require 'spec_helper'

describe Zendesk::Resource do
  context "update", :vcr_off do
    context "class method" do
      let(:id) { 1 }
      subject { Zendesk::TestResource }

      before(:each) do
        stub_request(:put, %r{test_resources/#{id}}).to_return(:body => {})
      end

      it "should return instance of resource" do
        subject.update(client, :id => id).should be_true
      end

      context "with client error" do
        before(:each) do
          stub_request(:put, %r{test_resources/#{id}}).to_return(:status => 500)
        end

        it "should handle it properly" do
          expect { silence_stdout{ subject.update(client, :id => id).should be_false } }.to_not raise_error
        end
      end
    end
  end

  context "destroy", :vcr_off do
    context "class method" do
      let(:id) { 1 }
      subject { Zendesk::TestResource }

      before(:each) do
        stub_request(:delete, %r{test_resources/#{id}}).to_return(:body => {})
      end

      it "should return instance of resource" do
        subject.destroy(client, :id => id).should be_true
      end

      context "with client error" do
        before(:each) do
          stub_request(:delete, %r{test_resources/#{id}}).to_return(:status => 500)
        end

        it "should handle it properly" do
          expect { silence_stdout{ subject.destroy(client, :id => id).should be_false } }.to_not raise_error
        end
      end
    end

    context "instance method" do
      subject { Zendesk::TestResource.new(client, :id => 1) }

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
          silence_stdout{ subject.destroy.should be_false }
          subject.destroyed?.should be_false
        end
      end
    end
  end

  context "save", :vcr_off do
    let(:id) { 1 }
    let(:attr) { { :param => "test" } }
    subject { Zendesk::TestResource.new(client, attr.merge(:id => id)) }

    before :each do
      stub_request(:put, %r{test_resources/#{id}}).to_return(:body => {"test_resource" => { :param => "abc" } })
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

    context "with client error" do
      before :each do
        stub_request(:put, %r{test_resources/1}).to_return(:status => 500)
      end

      it "should be properly handled" do
        expect { silence_stdout { subject.save.should be_false } }.to_not raise_error
      end
    end

    context "new record" do
      subject { Zendesk::TestResource.new(client, attr) }

      before :each do
        stub_request(:post, %r{test_resources}).to_return(:status => 201, :body => {"test_resource" => attr.merge(:id => id)})
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
          Zendesk::TestResource.associations.clear
          Zendesk::TestResource.has :child, :class => :test_child
          stub_request(:put, %r{test_resources}).to_return(:body => {})
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
          Zendesk::TestResource.associations.clear
          Zendesk::TestResource.has_many :children, :class => :test_child

          stub_request(:put, %r{test_resources}).to_return(:body => {})
          stub_request(:get, %r{children}).to_return(:body => {"test_children" => []})
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
    end
  end

  %w{put post delete}.each do |verb|
    context "on #{verb}", :vcr_off do
      let(:method) { "test_#{verb}_method" }
      before(:each) do
        Zendesk::TestResource.send(verb, method)
      end

      context "class method" do
        subject { Zendesk::TestResource }

        it "should create a method of the same name" do
          subject.instance_methods.map(&:to_s).should include(method)
        end
      end

      context "instance method" do
        subject { Zendesk::TestResource.new(client, :id => 1) }

        before(:each) do
          stub_request(verb.to_sym, %r{test_resources/1/#{method}}).to_return(:body => { "test_resources" => [{ "id" => 1, "method" => method }]})
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
            expect { silence_stdout{ subject.send(method).should be_false } }.to_not raise_error
          end
        end
      end
    end
  end
end

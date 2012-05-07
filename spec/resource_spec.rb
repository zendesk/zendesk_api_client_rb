require 'spec_helper'

describe Zendesk::Resource do
  context "update", :vcr_off do
    context "class method" do
      let(:id) { 1 }
      subject { Zendesk::TestResource }

      before(:each) do
        stub_request(:put, %r{test_resources/#{id}}).to_return({})
      end

      it "should return instance of resource" do
        subject.update(client, :id => id).should be_true
      end

      context "with client error" do
        before(:each) do
          stub_request(:put, %r{test_resources/#{id}}).to_return(:status => 500)
        end

        it "should handle it properly" do
          expect { subject.update(client, :id => id).should be_false }.to_not raise_error
        end
      end
    end
  end


  context "destroy", :vcr_off do
    context "class method" do
      let(:id) { 1 }
      subject { Zendesk::TestResource }

      before(:each) do
        stub_request(:delete, %r{test_resources/#{id}}).to_return({})
      end

      it "should return instance of resource" do
        subject.destroy(client, :id => id).should be_true
      end

      context "with client error" do
        before(:each) do
          stub_request(:delete, %r{test_resources/#{id}}).to_return(:status => 500)
        end

        it "should handle it properly" do
          expect { subject.destroy(client, :id => id).should be_false }.to_not raise_error
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
          subject.destroy.should be_false
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
      stub_request(:put, %r{test_resources/#{id}}).to_return(:body => { :param => "abc" })
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
        expect { subject.save.should be_false }.to_not raise_error
      end
    end

    context "new record" do
      subject { Zendesk::TestResource.new(client, attr) }

      before :each do
        stub_request(:post, %r{test_resources}).to_return(:status => 201, :body => attr.merge(:id => id))
      end

      it "should be true without an id" do
        subject.new_record?.should be_true
      end

      it "should post" do
        subject.save.should be_true
        subject.new_record?.should be_false
        subject.id.should == id
      end
    end

    context "with nested associations to save" do
      context "has" do
        before(:all) do
          Zendesk::TestResource.associations.clear
          Zendesk::TestResource.has :child, :class => :test_child, :save => true
        end

        before(:each) do
          stub_request(:put, %r{test_resources}).to_return(:body => {})
          subject.child_id = 1
        end

        context "with side-loaded resource" do
          context "with a hash" do
            before(:each) do
              subject.child = { :id => 2 }
              subject.child.should_receive(:save)
              subject.save
            end

            it "should save the new object" do
              subject.child.should be_instance_of(Zendesk::TestResource::TestChild)
            end

            specify "child's id" do
              subject.child.id.should == 2
              subject.child_id.should == 2
            end
          end
        end

        context "with an object" do
          context "with a hash" do
            before(:each) do
              subject.child = Zendesk::TestResource::TestChild.new(client, :abc => 1, :id => 2)
              subject.child.should_receive(:save)
              subject.save
            end

            it "should save the new object" do
              subject.child.should be_instance_of(Zendesk::TestResource::TestChild)
            end

            specify "child's id" do
              subject.child.id.should == 2
              subject.child_id.should == 2
            end
          end
        end
      end

      context "has_many" do
        before(:all) do
          Zendesk::TestResource.associations.clear
          Zendesk::TestResource.has_many :children, :class => :test_child, :save => true
        end

        before(:each) do
          stub_request(:put, %r{test_resources}).to_return(:body => {})
          stub_request(:get, %r{children}).to_return(:body => {"test_children" => []})
        end

        context "with side-loaded resource" do
          context "with a hash" do
            before(:each) do
              subject.child_ids = [1]
              subject.children = [2, 3]
              subject.save
            end

            it "should save the new object" do
              subject.children.should be_instance_of(Array)
            end

            specify "child's id" do
              [2,3].each {|id| subject.children.detect {|c| c.id == id}.should_not be_nil}
              subject.child_ids.should == [2, 3]
            end
          end
        end

        context "with an object" do
          context "with a hash" do
            let(:association) do
              Zendesk::Association.new(:class => Zendesk::TestResource::TestChild, :parent => Zendesk::TestResource.new(client, :id => 1))
            end
            before(:each) do
              collection = Zendesk::Collection.new(client, Zendesk::TestResource::TestChild,
                :association => association)
              collection << { :id => 2, :def => :abc, :test_resource_id => 1 }
              collection << { :id => 3, :def => :gre, :test_resource_id => 1 }
              subject.children = collection
              subject.save
            end

            it "should save the new object" do
              subject.children.should be_instance_of(Zendesk::Collection)
            end

            specify "child's id" do
              subject.children.collect(&:id).should == [2, 3]
            end
          end
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
            expect { subject.send(method).should be_false }.to_not raise_error
          end
        end
      end
    end
  end
end

require 'spec_helper.rb'

describe ZendeskAPI::Collection do
  subject do
    ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource)
  end

  context "initialization" do
    it "should set the resource class" do
      subject.instance_variable_get(:@resource_class).should == ZendeskAPI::TestResource
    end

    it "should initially be empty" do
      subject.instance_variable_defined?(:@resources).should be_false
    end
  end

  context "with array option passed in" do
    subject { ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource, :ids => [1, 2, 3, 4]) }

    it "should join array with commas" do
      subject.instance_variable_get(:@options)[:ids].should == "1,2,3,4"
    end
  end

  context "deferral" do
    before(:each) do
      stub_json_request(:any, %r{test_resources}, json(:test_resource => {}))
    end

    it "should defer #create to the resource class" do
      subject.create
    end

    it "should defer #find to the resource class" do
      subject.find(:id => 1)
    end

    it "should defer #destroy to the resource class" do
      subject.destroy(:id => 1)
    end

    it "should defer #update to the resource class" do
      subject.update(:id => 1)
    end

    context "with a class with a parent" do
      let(:association) do
        ZendeskAPI::Association.new(:class => ZendeskAPI::TestResource::TestChild,
          :parent => ZendeskAPI::TestResource.new(client, :id => 1))
      end

      subject do
        ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource::TestChild,
          :association => association)
      end

      before(:each) do
        stub_json_request(:any, %r{/test_resources/\d+/child}, json("test_child" => {}))
      end

      it "should defer #create to the resource class with the parent id" do
        subject.create
      end

      it "should defer #destroy the resource class with the parent id" do
        subject.destroy(:id => 1)
      end

      it "should defer #find to the resource class with the parent id" do
        subject.find(:id => 1)
      end

      it "should defer #update to the resource class with the parent id" do
        subject.update(:id => 1)
      end

      context "on object push" do
        before(:each) do
          stub_json_request(:get, %r{test_resources/\d+/children}, json(:test_children => []))
          subject << { :id => 1 }
        end

        it "should pass association" do
          subject.last.association.should == association
        end
      end
    end
  end

  context "pagination with no options and no data" do
    it "should return an empty array on #next" do
      subject.next.should be_empty
    end

    it "should return an empty array on #prev" do
      subject.prev.should be_empty
    end
  end

  context "pagination with options and no data" do
    before(:each) { subject.per_page(5).page(2) }

    it "should set per_page option" do
      subject.per_page(10).should == subject
      subject.instance_variable_get(:@options)["per_page"].should == 10
    end

    it "should set page option" do
      subject.page(10).should == subject
      subject.instance_variable_get(:@options)["page"].should == 10
    end

    it "should increate page option" do
      subject.next.should == 3
    end

    it "should decreate page option" do
      subject.prev.should == 1
    end
  end

  context "fetch" do
    it "does not fetch if associated is a new record" do
      ZendeskAPI::Category.new(client).forums.fetch.should == []
      ZendeskAPI::Category.new(client).forums.to_a.should == []
    end

    context "with client error" do
      before(:each) do
        stub_request(:get, %r{test_resources}).to_return(:status => 500)
      end

      it "should properly be handled" do
        silence_logger { subject.fetch(true).should be_empty }
      end
    end

    context "with unfetchable resource" do
      subject { ZendeskAPI::Collection.new(client, ZendeskAPI::NilResource) }

      it "should not call connection" do
        client.connection.should_not_receive(:get)
        subject.fetch(true).should be_empty
      end
    end
  end

  context "save" do
    let(:options) { { :abc => 1 } }
    before(:each) do
      stub_json_request(:get, %r{test_resources}, json(:test_resources => []))
      subject.clear_cache
    end

    context "with a hash" do
      let(:object) { mock('ZendeskAPI::TestResource', :changes => [:xxx]) }

      it "should call create with those options" do
        ZendeskAPI::TestResource.should_receive(:new).
          with(client, options.merge(:association => subject.association)).
          and_return(object)

        subject << options

        object.should_receive(:save)
        subject.save

        subject.should include(object)
      end
    end

    context "with a new object" do
      let(:object) { ZendeskAPI::TestResource.new(client, options) }
      before(:each) do
        subject << object
      end

      it "should save object" do
        object.should_receive(:save)
        subject.save
      end

      it "should have object in collection" do
        subject.should include(object)
      end
    end

    context "with everything else" do
      it "should pass to new, since this is how attachment handles it" do
        attachment = mock(:changes => [:xxx])
        ZendeskAPI::TestResource.should_receive(:new).with(client, "img.jpg").and_return attachment
        subject << "img.jpg"

        attachment.should_receive :save
        subject.save
      end
    end
  end

  context "without real data" do
    subject do
      ZendeskAPI::Collection.new(client, ZendeskAPI::User)
    end

    before(:each) do
      stub_json_request(:get, %r{users\?page=2}, json(
        :users => [{:id => 2}],
        :next_page => "/users?page=3&per_page=1",
        :previous_page => "/users?page=1&per_page=1"
      ))

      subject.per_page(1).page(2)
      subject.fetch(true)
    end

    context "pagination with no options" do
      before(:each) do
        stub_json_request(:get, %r{users\?page=(1|3)}, json(:users => [{:id => 3}]))

        subject.per_page(nil).page(nil)
      end

      it "should find the next page by calling fetch" do
        current = subject.to_a.dup
        nxt = subject.next

        nxt.size.should == 1
        nxt.should_not == current
      end

      it "should find the prev page by calling fetch" do
        current = subject.to_a.dup
        prev = subject.prev

        prev.size.should == 1
        prev.should_not == current
      end
    end

    context "pagination with options", :vcr do
      before(:each) { subject.per_page(1).page(2) }

      it "should increase page option and not call fetch" do
        subject.next.should == 3
      end

      it "should decrease page option and not call fetch" do
        subject.prev.should == 1
      end

      context "with page == 1" do
        before do
          subject.page(1)
          subject.clear_cache
          subject.should_not_receive(:fetch)
        end

        it "should do nothing on #prev" do
          subject.prev.should == []
        end
      end
    end
  end

  context "method missing" do
    before(:each) { subject.stub(:fetch).and_return([1, 2, nil, 3]) }

    context "with an class method on the resource class" do
      it "should pass methods to class if defined" do
        subject.test.should == "hi"
      end
    end

    it "should pass all methods not defined to resources" do
      subject.compact.should == [1, 2, 3]
    end

    it "should take a block" do
      subject.map {|i| i.to_i + 1}.should == [2, 3, 1, 4]
    end

    it "should create a new collection if it isn't an array method" do
      subject.recent.should be_instance_of(ZendeskAPI::Collection)
    end

    it "should pass the correct query_path to the new collection" do
      subject.recent.instance_variable_get(:@collection_path).last.should == :recent
    end
  end


  context "with different path" do
    subject do
      ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource, :collection_path => ["test_resources", "active"])
    end

    before(:each) do
      stub_json_request(:post, %r{test_resources/active})
    end

    context "deferral" do
      it "should defer #create to the resource class with proper path" do
        subject.create
      end
    end
  end
end

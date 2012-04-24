require 'spec_helper.rb'

describe Zendesk::Collection do
  let(:client) { valid_client }

  subject do
    Zendesk::Collection.new(client, "test_resources", ["test_resources"], {})
  end

  context "initialization" do
    it "should set the resource class" do
      subject.instance_variable_get(:@resource_class).should == Zendesk::TestResource
    end

    it "should initially be empty" do
      subject.instance_variable_defined?(:@resources).should be_false
    end
  end

  context "deferral" do
    it "should defer #create to the resource class" do
      Zendesk::TestResource.should_receive(:create).with(client, {}, "test_resources")
      subject.create
    end

    it "should defer #find to the resource class" do
      Zendesk::TestResource.should_receive(:find).with(client, 1, :path => "test_resources")
      subject.find(1)
    end

    it "should defer #destroy to the resource class" do
      Zendesk::TestResource.should_receive(:destroy).with(client, 1, "test_resources")
      subject.destroy(1)
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

  context "with real data", :vcr do
    subject do
      Zendesk::Collection.new(client, "users", ["users"], {})
    end

    before(:all) do
      VCR.use_cassette('collection_fetch_users') do
        subject.per_page(1).page(2)
        subject.fetch(true)
      end
    end

    context "pagination with no options" do
      use_vcr_cassette :record => :new_episodes

      before(:each) { subject.per_page(nil).page(nil) }

      it "should find the next page by calling fetch" do
        current = subject.to_a
        nxt = subject.next

        nxt.size.should == 1
        nxt.should_not == current
      end

      it "should find the prev page by calling fetch" do
        current = subject.to_a
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
          subject.clear
          subject.should_not_receive(:fetch)
        end

        it "should do nothing on #prev" do
          subject.prev.should == []
        end
      end
    end
  end

  context "method missing" do
    before(:each) { subject.should_receive(:fetch).and_return([1, 2, nil, 3]) }

    it "should pass all methods not defined to resources" do
      subject.compact.should == [1, 2, 3]
    end

    it "should take a block" do
      subject.map {|i| i.to_i + 1}.should == [2, 3, 1, 4]
    end
  end

  context "with different path" do
    subject do
      Zendesk::Collection.new(client, "test_resources", ["test_resources", "active"], {})
    end

    context "deferral" do
      it "should defer #create to the resource class with proper path" do
        Zendesk::TestResource.should_receive(:create).with(client, {}, "test_resources/active")
        subject.create
      end
    end
  end
end

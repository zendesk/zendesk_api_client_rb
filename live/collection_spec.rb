require 'spec_helper'

describe ZendeskAPI::Collection do
  subject do
    ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource)
  end

  context "with real data" do
    subject do
      ZendeskAPI::Collection.new(client, ZendeskAPI::User)
    end

    before(:all) do
      VCR.use_cassette('collection_fetch_users') do
        subject.per_page(1).page(2)
        subject.fetch(true)
      end
    end

    context "pagination with no options" do
      use_vcr_cassette

      before(:each) { subject.per_page(nil).page(nil) }

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

    context "pagination with options" do
      use_vcr_cassette

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
end

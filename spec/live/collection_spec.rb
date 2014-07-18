require 'core/spec_helper'

describe ZendeskAPI::Collection do
  subject do
    ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource)
  end

  context "with real data" do
    subject do
      ZendeskAPI::Collection.new(client, ZendeskAPI::User)
    end

    before(:each) do
      VCR.use_cassette('collection_fetch_users') do
        subject.per_page(1).page(2)
        subject.fetch(true)
      end
    end

    context "pagination with no options", :vcr do
      before(:each) { subject.per_page(nil).page(nil) }

      it "should find the next page by calling fetch" do
        current = subject.to_a.dup
        nxt = subject.next

        expect(nxt.size).to eq(1)
        expect(nxt).to_not eq(current)
      end

      it "should find the prev page by calling fetch" do
        current = subject.to_a.dup
        prev = subject.prev

        expect(prev.size).to eq(1)
        expect(prev).to_not eq(current)
      end
    end

    context "pagination with options", :vcr do
      before(:each) { subject.per_page(1).page(2) }

      it "should increase page option and not call fetch" do
        expect(subject.next).to eq(3)
      end

      it "should decrease page option and not call fetch" do
        expect(subject.prev).to eq(1)
      end

      context "with page == 1" do
        before do
          subject.page(1)
          subject.clear_cache
          expect(subject).to_not receive(:fetch)
        end

        it "should do nothing on #prev" do
          expect(subject.prev).to eq([])
        end
      end
    end
  end
end

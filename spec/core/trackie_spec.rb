require "core/spec_helper"

describe ZendeskAPI::Trackie do
  subject { ZendeskAPI::Trackie.new }
  before(:each) { subject.clear_changes }

  it "should not be changed" do
    expect(subject.changed?).to be(false)
  end

  context "adding keys" do
    before(:each) { subject[:key] = true }

    it "should include key in changes" do
      expect(subject.changes[:key]).to be(true)
    end

    specify "key should be changed" do
      expect(subject.changed?(:key)).to be(true)
      expect(subject.changed?).to be(true)
    end
  end

  context "deleting keys" do
    before(:each) do
      subject[:key] = true
    end

    it "returns key on deletion" do
      expect(subject.delete(:key)).to be(true)
    end

    context "after deletion" do
      before(:each) { subject.delete(:key) }

      it "keeps the changes" do
        expect(subject.changed?(:key)).to be(true)
      end
    end
  end

  context "adding identical keys" do
    before(:each) do
      subject[:key] = "foo"
      subject.clear_changes

      subject[:key] = "foo"
    end

    it "should not include key in changes" do
      expect(subject.changes[:key]).to be_falsey
    end

    specify "key should not be changed" do
      expect(subject.changed?(:key)).to be(false)
      expect(subject.changed?).to be(false)
    end
  end

  context "nested hashes" do
    before(:each) do
      subject[:key] = ZendeskAPI::Trackie.new
      subject.clear_changes
      subject[:key][:test] = true
    end

    it "should include changes from nested hash" do
      expect(subject.changes[:key][:test]).to be(true)
    end

    specify "subject should be changed" do
      expect(subject.changed?).to be(true)
    end
  end

  # TODO
  #   context "nested arrays" do
  #     before(:each) do
  #       subject[:key] = []
  #       subject.clear_changes
  #       subject[:key] << :test
  #     end
  #
  #     it "should include changes from nested array" do
  #       expect(subject.changes[:key]).to eq([:test])
  #     end
  #
  #     specify "subject should be changed" do
  #       expect(subject.changed?).to be(true)
  #     end
  #   end

  context "nested hashes in arrays" do
    before(:each) do
      subject[:key] = [ZendeskAPI::Trackie.new]
      subject.clear_changes
      subject[:key].first[:test] = true
    end

    it "should include changes from nested array" do
      expect(subject.changes[:key].first[:test]).to be(true)
    end

    specify "subject should be changed" do
      expect(subject.changed?).to be(true)
    end

    context "clearing" do
      before(:each) do
        subject.clear_changes
      end

      it "should not have any changes" do
        expect(subject.changes).to be_empty
      end
    end
  end

  describe "#size" do
    before do
      subject[:size] = 42
    end

    it "returns the value corresponding to the :size key" do
      expect(subject.size).to eq(42)
    end
  end
end

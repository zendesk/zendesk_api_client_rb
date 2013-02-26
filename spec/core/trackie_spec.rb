require 'core/spec_helper'

describe ZendeskAPI::Trackie do
  subject { ZendeskAPI::Trackie.new }
  before(:each) { subject.clear_changes }

  it "should not be changed" do
    subject.changed?.should be_false
  end

  context "adding keys" do
    before(:each) { subject[:key] = true }

    it "should include key in changes" do
      subject.changes[:key].should be_true
    end

    specify "key should be changed" do
      subject.changed?(:key).should be_true
      subject.changed?.should be_true
    end
  end

  context "adding identical keys" do
    before(:each) do
      subject[:key] = "foo"
      subject.clear_changes

      subject[:key] = "foo"
    end

    it "should not include key in changes" do
      subject.changes[:key].should be_false
    end

    specify "key should not be changed" do
      subject.changed?(:key).should be_false
      subject.changed?.should be_false
    end
  end

  context "nested hashes" do
    before(:each) do
      subject[:key] = ZendeskAPI::Trackie.new
      subject.clear_changes
      subject[:key][:test] = true
    end

    it "should include changes from nested hash" do
      subject.changes[:key][:test].should be_true
    end

    specify "subject should be changed" do
      subject.changed?.should be_true
    end
  end

  describe "#size" do
    before do
      subject[:size] = 42
    end

    it "returns the value corresponding to the :size key" do
      subject.size.should == 42
    end
  end
end

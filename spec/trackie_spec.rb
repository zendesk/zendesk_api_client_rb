require 'spec_helper'

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
end

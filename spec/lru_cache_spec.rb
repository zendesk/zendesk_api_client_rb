require 'spec_helper'

describe ZendeskAPI::LRUCache do
  let(:cache){ ZendeskAPI::LRUCache.new(2) }

  it "writes and reads" do
    cache.write("x", 1).should == 1
    cache.read("x").should == 1
  end

  it "drops" do
    cache.write("x", 1)
    cache.write("y", 1)
    cache.write("x", 1)
    cache.write("z", 1)
    cache.read("z").should == 1
    cache.read("x").should == 1
    cache.read("y").should == nil
  end

  it "fetches" do
    cache.fetch("x"){ 1 }.should == 1
    cache.read("x").should == 1
    cache.fetch("x"){ 2 }.should == 1
  end
end

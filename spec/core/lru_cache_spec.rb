require 'core/spec_helper'

describe ZendeskAPI::LRUCache do
  let(:cache) { ZendeskAPI::LRUCache.new(2) }

  it "writes and reads" do
    expect(cache.write("x", 1)).to eq(1)
    expect(cache.read("x")).to eq(1)
  end

  it "drops" do
    cache.write("x", 1)
    cache.write("y", 1)
    cache.write("x", 1)
    cache.write("z", 1)
    expect(cache.read("z")).to eq(1)
    expect(cache.read("x")).to eq(1)
    expect(cache.read("y")).to eq(nil)
  end

  it "fetches" do
    expect(cache.fetch("x") { 1 }).to eq(1)
    expect(cache.read("x")).to eq(1)
    expect(cache.fetch("x") { 2 }).to eq(1)
  end
end

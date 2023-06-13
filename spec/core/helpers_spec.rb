require 'core/spec_helper'

RSpec.describe ZendeskAPI::Helpers do
  describe "#present?" do
    it "is false when nil, or empty" do
      expect(described_class.present?(nil)).to be(false)
      expect(described_class.present?("")).to be(false)
      expect(described_class.present?(" ")).to be(false)
      expect(described_class.present?([])).to be(false)
      expect(described_class.present?({})).to be(false)
    end

    it "is true when there's something" do
      expect(described_class.present?(1)).to be(true)
      expect(described_class.present?(:a)).to be(true)
      expect(described_class.present?("b")).to be(true)
      expect(described_class.present?([:a])).to be(true)
      expect(described_class.present?(c: 3)).to be(true)
    end
  end
end

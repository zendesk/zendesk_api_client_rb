require "core/spec_helper"

describe String do
  specify "the plural of forum if forums" do
    expect(Inflection.plural("forum")).to eq("forums")
  end
end

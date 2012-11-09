require 'core/spec_helper'

describe String do
  specify "the plural of forum if forums" do
    Inflection.plural("forum").should == "forums"
  end
end

require 'spec_helper'

describe String do
  specify "the plural of forum if forums" do
    "forum".plural.should == "forums"
  end
end

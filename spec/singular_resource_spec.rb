require 'spec_helper'

describe Zendesk::SingularResource do
  context "class path" do
    subject { Zendesk::SingularTestResource }

    specify "path should not include id" do
      subject.path.should_not =~ /(%s)+/
    end
  end
end

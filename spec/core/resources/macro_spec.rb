require "core/spec_helper"

describe ZendeskAPI::Macro do
  def valid_attributes
    {
      :title => "my test macro",
      :actions => [{:field => "priority", :value => "urgent"}]
    }
  end

  subject do
    described_class.new(double, valid_attributes)
  end

  describe "#add_action" do
    it "should add an action to the current actions" do
      new_action = {:field => "status", :value => "solved"}
      existing_actions = subject.actions

      expect(existing_actions).not_to include(new_action)

      subject.add_action("status", "solved")

      expect(subject.actions).to eq(existing_actions << new_action)
    end
  end
end

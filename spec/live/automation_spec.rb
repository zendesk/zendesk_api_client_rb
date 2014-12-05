require 'core/spec_helper'

describe ZendeskAPI::Automation, :delete_after do
  def valid_attributes
    {
      :title => "my test automation",
      :conditions => {
        :all => [{ :field => "status", :operator => "is", :value => "open" }]
      },
      :actions => [{ :field => "status", :value => "solved" }]
    }
  end

  it_should_be_readable :automations
  it_should_be_readable :automations, :active

  it_should_be_creatable
  it_should_be_updatable :conditions, {
    "any" => [],
    "all" => [{ "field" => "status", "operator" => "is", "value" => "pending" }]
  }
  it_should_be_deletable

  subject do
    described_class.new(double, {
      :title => "my test automation",
      :conditions => {
        :any => [{ :field => "assignee_id", :operator => "is", :value => 1}],
        :all => [{ :field => "status", :operator => "is", :value => "open" }]
      },
      :actions => [{ :field => "priority", :value => "urgent" }],
    })
  end

  describe "#all_conditions=" do
    it "should assign new values to all conditions" do
      new_conditions = [
        { "field" => "type", "operator" => "is", "value" => "question" },
        { "field" => "status", "operator" => "less_than", "value" => "solved" }
      ]
      subject.all_conditions = new_conditions

      expect(subject.conditions[:all]).to eq(new_conditions)
    end
  end

  describe "#any_conditions=" do
    it "should assign new values to any conditions" do
      new_conditions = [
        { "field" => "type", "operator" => "is", "value" => "question" },
        { "field" => "status", "operator" => "less_than", "value" => "solved" }
      ]
      subject.any_conditions = new_conditions

      expect(subject.conditions[:any]).to eq(new_conditions)
    end
  end

  describe "#add_all_condition" do
    it "should add a condition to all condition" do
      new_condition = { :field => "type", :operator => "is", :value => "problem" }
      existing_conditions = subject.conditions[:all]

      expect(existing_conditions).not_to include(new_condition)

      subject.add_all_condition("type", "is", "problem")

      expect(subject.conditions[:all]).to eq(existing_conditions << new_condition)
    end
  end

  describe "#add_any_condition" do
    it "should add a condition to any condition" do
      new_condition = { :field => "type", :operator => "is", :value => "task" }
      existing_conditions = subject.conditions[:any]

      expect(existing_conditions).not_to include(new_condition)

      subject.add_any_condition("type", "is", "task")

      expect(subject.conditions[:any]).to eq(existing_conditions << new_condition)
    end
  end

  describe "#add_action" do
    it "should add an action to the current actions" do
      new_action = { :field => "status", :value => "solved" }
      existing_actions = subject.actions

      expect(existing_actions).not_to include(new_action)

      subject.add_action("status", "solved")

      expect(subject.actions).to eq(existing_actions << new_action)
    end
  end
end

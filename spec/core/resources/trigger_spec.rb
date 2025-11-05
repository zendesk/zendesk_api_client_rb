require "core/spec_helper"

describe ZendeskAPI::Trigger do
  def valid_attributes
    {
      :title => "my test trigger",
      :conditions => {
        :any => [{:field => "assignee_id", :operator => "is", :value => 1}],
        :all => [{:field => "status", :operator => "is", :value => "open"}]
      }
    }
  end

  subject do
    described_class.new(double, valid_attributes)
  end

  describe "#all_conditions=" do
    it "should assign new values to all conditions" do
      new_conditions = [
        {"field" => "type", "operator" => "is", "value" => "question"},
        {"field" => "status", "operator" => "less_than", "value" => "solved"}
      ]
      subject.all_conditions = new_conditions

      expect(subject.conditions[:all]).to eq(new_conditions)
    end
  end

  describe "#any_conditions=" do
    it "should assign new values to any conditions" do
      new_conditions = [
        {"field" => "type", "operator" => "is", "value" => "question"},
        {"field" => "status", "operator" => "less_than", "value" => "solved"}
      ]
      subject.any_conditions = new_conditions

      expect(subject.conditions[:any]).to eq(new_conditions)
    end
  end

  describe "#add_all_condition" do
    it "should add a condition to all condition" do
      new_condition = {:field => "type", :operator => "is", :value => "problem"}
      existing_conditions = subject.conditions[:all]

      expect(existing_conditions).not_to include(new_condition)

      subject.add_all_condition("type", "is", "problem")

      expect(subject.conditions[:all]).to eq(existing_conditions << new_condition)
    end
  end

  describe "#add_any_condition" do
    it "should add a condition to any condition" do
      new_condition = {:field => "type", :operator => "is", :value => "task"}
      existing_conditions = subject.conditions[:any]

      expect(existing_conditions).not_to include(new_condition)

      subject.add_any_condition("type", "is", "task")

      expect(subject.conditions[:any]).to eq(existing_conditions << new_condition)
    end
  end
end

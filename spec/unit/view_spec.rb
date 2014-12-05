require 'core/spec_helper'

describe ZendeskAPI::View do
  subject do
    described_class.new(double, {
      :title => "my test view",
      :conditions => {
        :any => [{ :field => "assignee_id", :operator => "is", :value => 1}],
        :all => [{ :field => "status", :operator => "is", :value => "open" }]
      },
      :execution => {
        :columns => [:id => "status", :title=> "Status"]
      }
    })
  end

  describe "#columns=" do
    it "should add a single column" do
      new_column = ["priority"]
      subject.columns = new_column

      expect(subject.output["columns"]).to eq(new_column)
    end

    it "should set columns on output" do
      new_columns = ["type", "priority"]
      subject.columns = new_columns

      expect(subject.output["columns"]).to eq(new_columns)
    end
  end

  describe "#add_column" do
    it "should add a column to the existing columns" do
      existing_columns = subject.execution.columns.map {|c| c["id"]}
      expect(existing_columns.include?("type")).to eq(false)

      subject.add_column("type")

      expect(subject.output["columns"]).to eq(existing_columns << "type")
    end
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
end

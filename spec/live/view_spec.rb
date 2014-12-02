require 'core/spec_helper'

describe ZendeskAPI::View, :delete_after do
  def valid_attributes
    {
      :title => "my test view",
      :conditions => {
        :all => [{ :field => "status", :operator => "is", :value => "open" }]
      }
    }
  end

  it_should_be_readable :views
  it_should_be_readable :views, :active

  it_should_be_creatable
  it_should_be_updatable :conditions, {
    "any" => [],
    "all" => [{ "field" => "status", "operator" => "is", "value" => "solved" }]
  }
  it_should_be_deletable

  describe "helper methods" do
    subject { @object }

    before :all do
      VCR.use_cassette("#{described_class}_add_column_view") do
        @object = described_class.create(client, valid_attributes.merge(default_options))
      end
    end

    after :all do
      VCR.use_cassette("#{described_class.to_s}_create_delete") do
        @object.destroy
      end
    end

    describe "#columns=" do
      it "should add a single column" do
        VCR.use_cassette("#{described_class}_add_single_column") do
          new_columns = ["priority"]
          subject.columns = new_columns

          expect(subject.execution.columns.map {|c| c["id"]}).to eq(new_columns)
        end
      end

      it "should add multiple columns" do
        VCR.use_cassette("#{described_class}_add_multiple_columns") do
          new_columns = ["type", "priority"]
          subject.columns = new_columns

          expect(subject.execution.columns.map {|c| c["id"]}).to eq(new_columns)
        end
      end
    end

    describe "#add_column" do
      it "should add a column to the existing columns" do
        VCR.use_cassette("#{described_class}_add_column") do
          existing_columns = subject.attributes.execution.columns.map {|c| c["id"]}
          expect(existing_columns.include?("type")).to eq(false)

          subject.add_column("type")

          expect(subject.execution.columns.map {|c| c["id"]}).to eq(existing_columns + ["type"])
        end
      end
    end

    describe "#all_conditions=" do
      it "should assign new values to all conditions" do
        VCR.use_cassette("#{described_class}_assign_all_condition") do
          new_conditions = [
            { "field" => "type", "operator" => "is", "value" => "question" },
            { "field" => "status", "operator" => "less_than", "value" => "solved" }
          ]
          subject.all_conditions = new_conditions

          expect(subject.conditions.to_hash["all"]).to eq(new_conditions)
        end
      end
    end

    describe "#any_conditions=" do
      it "should assign new values to any conditions" do
        VCR.use_cassette("#{described_class}_assign_any_condition") do
          new_conditions = [
            { "field" => "type", "operator" => "is", "value" => "question" },
            { "field" => "status", "operator" => "less_than", "value" => "solved" }
          ]
          subject.any_conditions = new_conditions

          expect(subject.conditions.to_hash["any"]).to eq(new_conditions)
        end
      end
    end

    describe "#add_all_condition" do
      it "should add a condition to all condition" do
        VCR.use_cassette("#{described_class}_add_all_condition") do
          new_condition = { "field" => "type", "operator" => "is", "value" => "problem" }
          existing_conditions = subject.conditions.to_hash["all"]

          expect(existing_conditions.include?(new_condition)).to eq(false)

          subject.add_all_condition("type", "is", "problem")

          expect(subject.conditions.to_hash["all"]).to eq(existing_conditions << new_condition)
        end
      end
    end

    describe "#add_any_condition" do
      it "should add a condition to any condition" do
        VCR.use_cassette("#{described_class}_add_any_condition") do
          new_condition = { "field" => "type", "operator" => "is", "value" => "task" }
          existing_conditions = subject.conditions.to_hash["any"]

          expect(existing_conditions.include?(new_condition)).to eq(false)

          subject.add_any_condition("type", "is", "task")

          expect(subject.conditions.to_hash["any"]).to eq(existing_conditions << new_condition)
        end
      end
    end
  end
end

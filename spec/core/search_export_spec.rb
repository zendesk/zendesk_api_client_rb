require "core/spec_helper"

describe ZendeskAPI::SearchExport do
  describe ".new" do
    context "when given an existing class" do
      it "returns an instance of the specific class" do
        expect(ZendeskAPI::SearchExport.new(nil, "result_type" => "user")).to be_instance_of(ZendeskAPI::User)
      end
    end

    context "when given a nonexistent class" do
      it "returns an instance of the generic Search::Result" do
        expect(ZendeskAPI::SearchExport.new(nil, "result_type" => "blah")).to be_instance_of(ZendeskAPI::SearchExport::Result)
      end
    end

    context "when not given anything" do
      it "returns an instance of Search::Result by default" do
        expect(ZendeskAPI::SearchExport.new(nil, {})).to be_instance_of(ZendeskAPI::SearchExport::Result)
      end
    end
  end
end

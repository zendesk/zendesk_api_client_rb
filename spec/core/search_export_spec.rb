require 'core/spec_helper'

describe ZendeskAPI::SearchExport do
  context ".new" do
    context "when given an existing class" do
      it "should return the correct class" do
        expect(ZendeskAPI::SearchExport.new(nil, { "result_type" => "user" })).to be_instance_of(ZendeskAPI::User)
      end
    end

    context "when given a nonexistent class" do
      it "should return an object of the type Search::Result" do
        expect(ZendeskAPI::SearchExport.new(nil, { "result_type" => "blah" })).to be_instance_of(ZendeskAPI::SearchExport::Result)
      end
    end

    context "when not given anything" do
      it "should return an object of the type Search::Result" do
        expect(ZendeskAPI::SearchExport.new(nil, {})).to be_instance_of(ZendeskAPI::SearchExport::Result)
      end
    end
  end
end

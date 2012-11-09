require 'core/spec_helper'

describe ZendeskAPI::Search do
  context ".new" do
    context "when given an existing class" do
      it "should return the correct class" do
        ZendeskAPI::Search.new(nil, { "result_type" => "user" }).should be_instance_of(ZendeskAPI::User)
      end
    end

    context "when given a nonexistant class" do
      it "should return an object of the type Search::Result" do
        ZendeskAPI::Search.new(nil, { "result_type" => "blah" }).should be_instance_of(ZendeskAPI::Search::Result)
      end
    end

    context "when not given anything" do
      it "should return an object of the type Search::Result" do
        ZendeskAPI::Search.new(nil, {}).should be_instance_of(ZendeskAPI::Search::Result)
      end
    end
  end
end

describe ZendeskAPI::Search do
  context ".new" do
    context "when given an existing class" do
      it "should return the correct class" do
        expect(ZendeskAPI::Search.new(nil, {"result_type" => "user"})).to be_instance_of(ZendeskAPI::User)
      end
    end

    context "when given a nonexistent class" do
      it "should return an object of the type Search::Result" do
        expect(ZendeskAPI::Search.new(nil, {"result_type" => "blah"})).to be_instance_of(ZendeskAPI::Search::Result)
      end
    end

    context "when not given anything" do
      it "should return an object of the type Search::Result" do
        expect(ZendeskAPI::Search.new(nil, {})).to be_instance_of(ZendeskAPI::Search::Result)
      end
    end
  end
end

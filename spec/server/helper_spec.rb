require 'server/spec_helper'

describe ZendeskAPI::Server::Helper do
  subject do
    Class.new do
      include ZendeskAPI::Server::Helper
      def params; @params ||= {}; end
    end.new
  end

  context "coerce path" do
    let(:coerced) do
      subject.coerce_path(path)
    end

    context "with no protocol" do
      let(:path) { "smersh.zendesk.com/api/v2/users" }

      it "should be assumed as https" do
        coerced.should == "users"
        subject.params["url"].should == "https://smersh.zendesk.com/api/v2"
      end
    end

    context "with no .zendesk.com" do
      let(:path) { "smersh/api/v2/users" }

      it "should fill in https and .zendesk.com" do
        coerced.should == "users"
        subject.params["url"].should == "https://smersh.zendesk.com/api/v2"
      end
    end

    context "with no .zendesk.com and no /api/v2" do
      let(:path) { "smersh/users" }

      it "should fill in https and .zendesk.com" do
        coerced.should == "users"
        subject.params["url"].should == "https://smersh.zendesk.com/api/v2"
      end
    end

    context "with an https url" do
      let(:path) { "https://smersh.zendesk.com/api/v2/users" }

      it "should not change anything" do
        coerced.should == "users"
        subject.params["url"].should == "https://smersh.zendesk.com/api/v2"
      end
    end

    context "with an http url" do
      let(:path) { "http://smersh.zendesk.com/api/v2/users" }

      it "should set the error" do
        coerced.should == path
        subject.instance_variable_get(:@error).should_not be_nil
      end
    end
  end

  context "execute request" do
    before do
      subject.params.merge!(:username => "me", :password => "2", :url => "https://somewhere.com")
    end

    it "should return error if invalid method" do
      subject.instance_variable_set(:@method, "BLARGHL")
      subject.execute_request
      subject.instance_variable_get(:@error).should_not be_nil
    end

    context "valid request" do
    end
  end

  context "map headers" do
    it "should combine headers" do
      subject.map_headers("accept-encoding" => "true", "hello" => "123").should ==
        "Accept-Encoding: true\nHello: 123"
    end
  end

  context "client" do
    it "should set configuration options" do
      subject.client(:username => "me", :password => "2", :url => "https://somewhere").should_not be_nil
    end

    it "should not allow http in production" do
      app.stub(:development? => false)

      expect do
        subject.client(:url => "somewhere")
      end.to raise_error ArgumentError
    end
  end
end

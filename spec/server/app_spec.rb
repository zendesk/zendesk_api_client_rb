require 'server/spec_helper'

describe ZendeskAPI::Server::App do
  describe "configuration" do
    subject { described_class.settings }

    describe "documentation" do
      # TODO
    end
  end

  describe "a GET to /" do
    before { get '/' }

    it "should respond ok" do
      last_response.status.should == 200
    end
  end

  describe "a GET to /:object_id" do
    describe "with a stored object" do
      subject do
        ZendeskAPI::Server::UserRequest.create(
          :username => "test",
          :method => :post,
          :url => "http://my.url.com",
          :json => '{"hello": "goodbye"}',
          :url_params => [{ :name => :a, :value => :b }],
          :request => {}, # TODO
          :response => {}
        )
      end

      before { get "/#{subject._id}" }

      it "should respond ok" do
        last_response.status.should == 200
      end

      it "should fill in url field" do
        last_response.body.should include "value='http://my.url.com'"
      end

      it "should fill in json field" do
        last_response.body.should include subject.json
      end

      it "should select the proper method" do
        last_response.body.should include "selected='selected' value='POST'"
      end

      it "should add url param" do
        last_response.body.should include "value='a'"
        last_response.body.should include "value='b'"
      end
    end

    describe "with no object" do
      before { get '/1234567876543' }

      it "should respond ok" do
        last_response.status.should == 200
      end
    end
  end

  describe "a POST to /" do
    describe "valid" do
      before do
        stub_json_request(:put, "https://me:2@smersh.zendesk.com/api/v2/users.json?id=1").with(:body => '{"hello":1}')

        post '/', :method => "PUT", :url => "https://smersh.zendesk.com/api/v2/users.json",
          :params => [{ "name" => "id", "value" => "1" }, {}], :json => '{"hello":1}',
          :username => "me", :password => "2"
      end

      it "should return ok" do
        last_response.status.should == 200
      end
    end

    describe "invalid" do
      before do
        post '/', :method => "OMG", :url => "https://nowheresville.com",
          :params => [{ "name" => "", "value" => "11243" }, {}], :json => '{"hello":1}',
          :username => "me", :password => "2"
      end

      it "should return ok" do
        last_response.status.should == 200
      end
    end
  end

  describe "a POST to /search" do
    subject do
      post '/search', :query => query
      last_response.body
    end

    describe "valid documentation" do
      let(:query) { "users" }

      it "should return the correct documentation" do
        should == described_class.settings.documentation["users"][:body]
      end
    end

    describe "invalid query" do
      let(:query) { "omgnotreal" }

      it "should return the introduction" do
        should == described_class.settings.help
      end
    end
  end
end

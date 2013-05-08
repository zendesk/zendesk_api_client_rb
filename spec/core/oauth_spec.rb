require 'core/spec_helper'

describe ZendeskAPI::OAuth do
  subject { client }

  context "with :client_id" do
    before { subject.config.oauth_options[:client_id] = "id" }

    it "should raise an error if no :client_secret" do
      expect { subject.oauth }.to raise_error(ArgumentError)
    end
  end

  context "with :client_secret" do
    before { subject.config.oauth_options[:client_secret] = "secret" }

    it "should raise an error if no :client_id" do
      expect { subject.oauth }.to raise_error(ArgumentError)
    end
  end

  context "valid" do
    before do
      subject.config.oauth_options = {
        :client_id => "identifier",
        :client_secret => "secret"
      }
    end

    it "should return an instance of OAuth2" do
      subject.oauth.should be_instance_of(OAuth2::Client)
    end

    context "with an api/v2 url" do
      before do
        subject.config.url = "https://www.example.com/api/v2"
      end

      it "should have the proper base url" do
        subject.oauth.site.should == "https://www.example.com"
      end
    end
  end
end

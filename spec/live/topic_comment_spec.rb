require 'core/spec_helper'

describe ZendeskAPI::Topic::TopicComment do
  def valid_attributes
    { :body => "Texty-text, text." }
  end

  under topic do
    it_should_be_creatable
    it_should_be_updatable :body
    it_should_be_deletable
    it_should_be_readable topic, :comments
  end

  describe ".import" do
    it "can import" do
      VCR.use_cassette("topic_comment_import_can_import") do
        old = Time.now - 4*365*24*60*60
        comment = ZendeskAPI::Topic::TopicComment.import(client, valid_attributes.merge(:created_at => old, :topic_id => topic.id))
        ZendeskAPI::Topic::TopicComment.find(client, comment).created_at.year.should == old.year
      end
    end

    it "returns nothing if import fails" do
      VCR.use_cassette("topic_comment_import_cannot_import") do
        silence_logger { ZendeskAPI::Topic::TopicComment.import(client, {}).should == nil }
      end
    end
  end
end

describe ZendeskAPI::User::TopicComment do
  def valid_attributes
    { :body => "Texty-text, text."}
  end

  under current_user do
    it_should_be_readable current_user, :topic_comments
  end
end

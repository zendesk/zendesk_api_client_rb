require 'core/spec_helper'

describe ZendeskAPI::TopicComment do
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
        comment = ZendeskAPI::TopicComment.import(client, valid_attributes.merge(:created_at => old, :topic_id => topic.id))
        expect(ZendeskAPI::TopicComment.find(client, comment).created_at.year).to eq(old.year)
      end
    end

    it "returns nothing if import fails" do
      VCR.use_cassette("topic_comment_import_cannot_import") do
        silence_logger { expect(ZendeskAPI::TopicComment.import(client, {})).to eq(nil) }
      end
    end
  end

  it "can upload while creating" do
    VCR.use_cassette("topic_comment_inline_uploads") do
      comment = ZendeskAPI::TopicComment.new(client, valid_attributes.merge(:topic_id => topic.id))
      comment.uploads << "spec/fixtures/Argentina.gif"
      comment.uploads << File.new("spec/fixtures/Argentina.gif")

      comment.save!
      expect(comment.changes).to eq({}) # uploads were set before save
      expect(comment.attributes[:uploads].map(&:class)).to eq([String, String]) # upload was sent as tokens
    end
  end
end

describe ZendeskAPI::TopicComment do
  def valid_attributes
    { :body => "Texty-text, text."}
  end

  under current_user do
    it_should_be_readable current_user, :topic_comments
  end
end

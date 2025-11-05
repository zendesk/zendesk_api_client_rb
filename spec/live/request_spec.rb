require "core/spec_helper"

describe ZendeskAPI::Request do
  def valid_attributes
    {
      subject: "This is a question!",
      comment: {value: "Haha, no."}
    }
  end

  it_should_be_creatable
  it_should_be_updatable :solved, true, {comment: {value: "This is solved!"}}
  it_should_be_readable :requests
  it_should_be_readable user, :requests

  it "can upload while creating" do
    VCR.use_cassette("request_inline_uploads") do
      request = ZendeskAPI::Request.new(client, valid_attributes)
      request.comment.uploads << "spec/fixtures/Argentina.gif"
      request.comment.uploads << File.new("spec/fixtures/Argentina.gif")

      request.save!
      expect(request.changes).to eq({}) # uploads were set before save
      expect(request.comment.attributes[:uploads].map(&:class)).to eq([String, String]) # upload was sent as tokens
    end
  end

  it "can comment while creating" do
    VCR.use_cassette("request_inline_comments") do
      request = ZendeskAPI::Request.new(client, valid_attributes)
      request.comment = ZendeskAPI::Request::Comment.new(client, value: "My comment")
      request.save!

      expect(request.changes).to eq({}) # comment was set before save
      expect(request.attributes[:comment]).to eq({"value" => "My comment"})
    end
  end
end

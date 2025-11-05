RSpec.describe ZendeskAPI::Topic do
  def valid_attributes
    {
      name: "My Topic",
      description: "The mayan calendar ends December 31st. Coincidence? I think not."
    }
  end

  it_should_be_creatable
  it_should_be_updatable :title
  it_should_be_deletable create: true
  it_should_be_readable :topics

  it "can upload while creating" do
    VCR.use_cassette("topic_inline_uploads") do
      topic = ZendeskAPI::Topic.new(client, valid_attributes)
      topic.uploads << "spec/fixtures/Argentina.gif"
      topic.uploads << File.new("spec/fixtures/Argentina.gif")

      topic.save!
      expect(topic.changes).to eq({}) # uploads were set before save
      expect(topic.attributes[:uploads].map(&:class)).to eq([String, String]) # upload was sent as tokens
    end
  end
end

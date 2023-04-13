require 'core/spec_helper'

RSpec.describe ZendeskAPI::Topic do
  before :all do
    VCR.configure do |c|
      @previous_allow_http_connections = c.allow_http_connections_when_no_cassette?
      c.allow_http_connections_when_no_cassette = true
    end
    client.topics.fetch!.map(&:destroy!)
  ensure
    VCR.configure do |c|
      c.allow_http_connections_when_no_cassette = @previous_allow_http_connections
    end
  end

  def valid_attributes
    {
      :name => "My Topic",
      :description => "The mayan calendar ends December 31st. Coincidence? I think not."
    }
  end

  it_should_be_creatable
  it_should_be_updatable :title
  it_should_be_deletable :create => true
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

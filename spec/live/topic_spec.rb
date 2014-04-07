require 'core/spec_helper'

describe ZendeskAPI::Topic do
  def valid_attributes
    {
      :forum_id => forum.id, :title => "My Topic",
      :body => "The mayan calendar ends December 31st. Coincidence? I think not."
    }
  end

  it_should_be_creatable
  it_should_be_updatable :title
  it_should_be_deletable :create => true
  it_should_be_readable :topics
  it_should_be_readable current_user, :topics
  it_should_be_readable forum, :topics
  #it_should_be_readable :topics, :show_many, :verb => :post, :ids =>

  describe ".import" do
    it "can import" do
      VCR.use_cassette("topic_import_can_import") do
        old = Time.now - 5*365*24*60*60
        topic = ZendeskAPI::Topic.import(client, valid_attributes.merge(:created_at => old))
        ZendeskAPI::Topic.find(client, topic).created_at.year.should == old.year
      end
    end

    it "returns nothing if import fails" do
      VCR.use_cassette("topic_import_cannot_import") do
        silence_logger { ZendeskAPI::Topic.import(client, {}).should == nil }
      end
    end
  end
end

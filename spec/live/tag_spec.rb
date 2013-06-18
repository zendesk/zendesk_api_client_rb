require 'core/spec_helper'

describe ZendeskAPI::Tag, :vcr, :not_findable do
  def valid_attributes
    { :id => "tag1" }
  end

  it_should_be_readable :tags

  [organization, topic, ticket].each do |object|
    under object do
      before(:each) do
        parent.tags = %w{tag2 tag3}
        parent.tags.save!
      end

      it "can be set" do
        tags.should == %w{tag2 tag3}
      end

      it "should be removable" do
        parent.tags.delete!("tag2")

        tags.should == %w{tag3}
      end

      it "should be updatable" do
        parent.tags.update!("tag4")

        tags.should == %w{tag2 tag3 tag4}
      end
    end
  end

  def tags
    parent.tags.fetch!(:reload).map(&:id).sort
  end
end

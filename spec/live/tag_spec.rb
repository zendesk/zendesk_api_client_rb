require "core/spec_helper"

RSpec.describe ZendeskAPI::Tag, :vcr, :not_findable do
  [organization, user, ticket].each do |object|
    raise "Your setup is invalid, see spec/live/Readme.md" unless object

    under object do
      before do
        parent.tags = %w[tag2 tag3]
        parent.tags.save!
      end

      it "can be set" do
        expect(tags).to eq(%w[tag2 tag3])
      end

      it "should be removable" do
        parent.tags.destroy!(id: "tag2")

        expect(tags).to eq(%w[tag3])
      end

      it "shouldn't re-save destroyed tags" do
        parent.tags.first.destroy!
        parent.tags.save!

        expect(tags).to eq(%w[tag3])
      end

      it "should be updatable" do
        parent.tags.update!(id: "tag4")

        expect(tags).to eq(%w[tag2 tag3 tag4])
      end

      it "should be savable" do
        parent.tags << "tag4"
        parent.tags.save!

        expect(tags).to eq(%w[tag2 tag3 tag4])
      end

      it "should be modifiable" do
        parent.tags.delete(ZendeskAPI::Tag.new(nil, id: "tag2"))
        parent.tags.save!

        expect(tags).to eq(%w[tag3])

        parent.tags.delete_if { |tag| tag.id == "tag3" }
        parent.tags.save!

        expect(tags).to be_empty
      end
    end
  end

  def tags
    parent.tags.fetch!(:reload).map(&:id).sort
  end
end

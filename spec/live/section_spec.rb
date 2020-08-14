require 'core/spec_helper'

describe ZendeskAPI::Section, :delete_after do
  it "expects section to exist" do
    expect(section).not_to be_nil
  end

  describe "creating sections withing categories" do
    def valid_attributes
      { :name => "My Section" }
    end

    let(:category_section) do
      VCR.use_cassette('create_section_within_category') do
        category.sections.create(valid_attributes)
      end
    end

    after do
      VCR.use_cassette('delete_section_within_category') do
        category_section.destroy
      end
    end

    it "can be created" do
      expect(category_section).not_to be_nil
    end
  end
end

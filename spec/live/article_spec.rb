require 'core/spec_helper'

RSpec.describe ZendeskAPI::Article, :delete_after do
  it "expects article to exist" do
    expect(article).not_to be_nil
  end

  it "can have translations", :vcr do
    article.translations.create(locale: "fr", title: "Traduction", body: "Bonjour")

    expect(article.translations.map(&:locale)).to include("fr")
  end

  describe "creating articles within a section" do
    def valid_attributes
      { :name => "My Article", user_segment_id: nil, permission_group_id: 2801272, title: "My super article" }
    end

    let(:section_article) do
      VCR.use_cassette('create_article_within_section') do
        section.articles.create(valid_attributes)
      end
    end

    after do
      VCR.use_cassette('delete_article_within_section') do
        section_article.destroy
      end
    end

    it "can be created" do
      expect(section_article).not_to be_nil
    end

    describe "#search" do
      before { section_article }

      it "finds the article", :vcr do
        actual = client.articles.search(query: "What")

        expect(actual.count).to be > 0
        expect(actual.last.title).to eq("What are these sections and articles doing here?")
        expect(actual.last.votes.any?).to be(true) # Manually set in UI
      end
    end
  end
end

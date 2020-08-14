require 'core/spec_helper'

describe ZendeskAPI::Article, :delete_after do
  it "expects article to exist" do
    expect(article).not_to be_nil
  end

  describe "creating articles withing sections" do
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
  end
end

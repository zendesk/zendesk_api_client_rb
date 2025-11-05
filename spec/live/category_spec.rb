require "core/spec_helper"

describe ZendeskAPI::Category, :delete_after do
  def valid_attributes
    { :name => "My Category" }
  end

  it "can have translations", :vcr do
    category.translations.create(locale: "fr-ca", title: "Traduction", body: "Bon matin")

    expect(category.translations.map(&:locale)).to include("fr-ca")
  end

  it_should_be_creatable
  it_should_be_updatable :position, 2
  it_should_be_deletable
  it_should_be_readable :categories, :create => true
end

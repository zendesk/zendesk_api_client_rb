describe ZendeskAPI::DynamicContent::Item, :delete_after do
  def valid_attributes
    {
      name: "Dynamic Content Item name Ruby SDK test",
      default_locale_id: 1,
      content: "Ruby SDK test content"
    }
  end

  it_should_be_readable :dynamic_content, :items, create: true
  it_should_be_creatable
  it_should_be_updatable :name, "Updated Dynamic Content Item name Ruby SDK test"
  it_should_be_deletable
end

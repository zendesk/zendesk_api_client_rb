RSpec.describe ZendeskAPI::Webhook, :delete_after do
  def valid_attributes
    {
      name: "Random Hook",
      endpoint: "https://lvh.me",
      status: :active,
      http_method: :get,
      request_format: :json
    }
  end

  it_should_be_creatable
  it_should_be_deletable
end

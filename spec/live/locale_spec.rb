require "core/spec_helper"

describe ZendeskAPI::Locale, :vcr do
  specify "client#current_locale" do
    expect(client.current_locale).to be_instance_of(described_class)
  end

  it_should_be_readable :locales
end

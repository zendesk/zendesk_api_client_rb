require 'core/spec_helper'

describe ZendeskAPI::Locale, :vcr do
  specify "client#current_locale" do
    client.current_locale.should be_instance_of(described_class)
  end

  it_should_be_readable :locales
end

require 'spec_helper'

describe Zendesk::Locale do
  use_vcr_cassette

  specify "client#current_locale" do
    client.locale.should be_instance_of(described_class)
  end

  it_should_be_readable :locales
end

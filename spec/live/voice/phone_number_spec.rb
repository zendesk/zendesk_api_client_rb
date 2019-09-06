require 'core/spec_helper'

describe ZendeskAPI::Voice::PhoneNumber, :delete_after do
  # We have to find a valid token before we create a phone number
  def available_phone_token
    @available_phone_token ||= begin
      VCR.use_cassette("find_valid_phone_number_token_for_creation") do
        client.voice.phone_numbers(
          path: "channels/voice/phone_numbers/search.json", country: "US"
        ).first.token
      end
    end
  end

  def valid_attributes
    {
      token: available_phone_token
    }
  end

  it_should_be_creatable

  # TODO: currently is a bit complicate to find / create the resource since
  # we need to prefetch an available token, which complicates how we can create to then
  # destroy a resource.
  # it_should_be_deletable
end

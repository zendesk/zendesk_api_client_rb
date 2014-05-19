require 'core/spec_helper'

describe ZendeskAPI::Voice::PhoneNumber, :delete_after do
  def valid_attributes
    {:number => "+14434064759", :country_code => "US", :toll_free => "false"}
  end

  it_should_be_creatable
  it_should_be_updatable :nickname
  it_should_be_updatable :transcription
  it_should_be_updatable :recorded
  it_should_be_deletable
end

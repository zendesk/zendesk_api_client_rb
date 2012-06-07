require 'spec_helper'

describe ZendeskAPI::SatisfactionRating do
  it_should_be_readable :satisfaction_ratings
  it_should_be_readable :satisfaction_ratings, :received
end

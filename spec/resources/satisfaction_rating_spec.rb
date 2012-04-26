require 'spec_helper'

describe Zendesk::SatisfactionRating do
  it_should_be_readable :satisfaction_ratings
  it_should_be_readable :satisfaction_ratings, :received
end

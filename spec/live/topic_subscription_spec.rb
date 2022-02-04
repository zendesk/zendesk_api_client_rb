require 'core/spec_helper'

describe ZendeskAPI::TopicSubscription, :delete_after, :not_findable do
  let!(:subscription) do
    VCR.use_cassette("create_inline_topic_subscription") do
      topic.subscriptions.create!(user_id: user.id, topic_id: topic.id)
    end
  end

  it_should_be_readable topic, :subscriptions
end

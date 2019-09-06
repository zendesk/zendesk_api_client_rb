require 'core/spec_helper'

describe ZendeskAPI::TopicSubscription, :delete_after, :not_findable do
  let!(:subscription) do
    VCR.use_cassette("create_inline_topic_subscription") do
      topic.subscriptions.create!(user_id: user.id, topic_id: topic.id)
    end
  end

  it_should_be_readable topic, :subscriptions

  # TODO: This resource cannot be found since the response from the server
  # is using `subscription` as the model name, instead of `topic_subscription`
  # which is what the save handle_response method is expecting:
  # https://github.com/zendesk/zendesk_api_client_rb/blob/master/lib/zendesk_api/actions.rb#L5
  # we should modify it to use the `model_key` if present, but I don't want to do
  # that now, when I modifying a lot of tests
  xit "subscription can be found via the topic" do
    VCR.use_cassette("find_created_topic_subscription") do
      expect(topic.subscriptions.find(id: subscription.id)).not_to be nil
    end
  end
end

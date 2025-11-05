require "core/spec_helper"

describe ZendeskAPI::PushNotificationDevice do
  describe ".destroy_many" do
    describe "Existing push notification devices" do
      it "destroys the given push notification devices" do
        VCR.use_cassette("push_notification_devices_destroy_many") do
          ZendeskAPI::PushNotificationDevice.destroy_many(client, %w[foo bar])
        end
      end
    end

    describe "Non-existing devices" do
      it "silently ignores the devices" do
        VCR.use_cassette("push_notification_devices_destroy_many") do
          ZendeskAPI::PushNotificationDevice.destroy_many(client, ["baz"])
        end
      end
    end
  end
end

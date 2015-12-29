module ZendeskAPI
  class PushNotificationDevice < DataResource
    def self.destroy_many(client, tokens)
      ZendeskAPI::Collection.new(
        client, self,"push_notification_devices" => tokens,
        :path => "push_notification_devices/destroy_many",
        :verb => :post
      )
    end
  end
end

module ZendeskAPI
  class UserView < Rule
    def self.preview(client, options = {})
      Collection.new(client, UserViewRow, options.merge!(:path => "user_views/preview", :verb => :post))
    end
  end
end

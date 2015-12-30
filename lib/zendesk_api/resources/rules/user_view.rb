module ZendeskAPI
  class UserView < Rule
    self.resource_name = 'user_views'
    self.singular_resource_name = 'user_view'

    self.collection_paths = ['user_views']
    self.resource_paths = ['user_views/%{id}']

    # TODO
    def self.preview(client, options = {})
      Collection.new(client, UserViewRow, options.merge!(:path => "user_views/preview", :verb => :post))
    end
  end
end

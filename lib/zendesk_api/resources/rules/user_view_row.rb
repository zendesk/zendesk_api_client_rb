module ZendeskAPI
  class UserViewRow < DataResource
    has :user, class: 'User'

    def self.model_key
      "rows"
    end
  end
end

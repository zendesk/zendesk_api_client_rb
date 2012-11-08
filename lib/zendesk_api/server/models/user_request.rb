module ZendeskAPI::Server
  class UserRequest
    include Mongoid::Document

    field :username, :type => String
    # field :password, :type => String
    field :method, :type => Symbol
    field :subdomain, :type => String
    field :path, :type => String
    field :json, :type => String
    field :url_params, :type => Array

    field :request, :type => String
    field :response, :type => String
  end
end

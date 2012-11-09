module ZendeskAPI::Server
  class UserRequest
    include Mongoid::Document

    field :method, :type => Symbol
    field :url, :type => String
    field :json, :type => String
    field :url_params, :type => Array

    field :request, :type => Hash
    field :response, :type => Hash
  end
end

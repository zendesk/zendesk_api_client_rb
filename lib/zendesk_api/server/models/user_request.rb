require 'zendesk_api/server/models/zlib_json'

module ZendeskAPI::Server
  class UserRequest
    include Mongoid::Document

    field :method, :type => Symbol
    field :url, :type => String
    field :path, :type => String
    field :json, :type => String
    field :url_params, :type => Array

    field :request, :type => ZlibJSON
    field :response, :type => ZlibJSON
  end
end

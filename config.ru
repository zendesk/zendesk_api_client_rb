require 'rack/ssl-enforcer'
require 'zendesk_api'
require 'zendesk_api/server/base'

use Rack::SslEnforcer if ZendeskAPI::Server::App.production?
run ZendeskAPI::Server::App

require 'rack-secure_only'

require 'zendesk_api'
require 'zendesk_api/server/base'

use Rack::SecureOnly, :if => ZendeskAPI::Server::App.production?
run ZendeskAPI::Server::App

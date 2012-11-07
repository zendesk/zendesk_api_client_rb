require 'rack-secure_only'
require './base'

use Rack::SecureOnly, :if => ZendeskAPI::Server::App.production?
run ZendeskAPI::Server::App

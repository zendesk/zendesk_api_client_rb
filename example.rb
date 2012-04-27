#!/usr/bin/env bundle exec ruby
require 'zendesk'
require 'ruby-debug'
Debugger.settings[:autoeval] = true

client = Zendesk.configure do |config|
  config.username = "agent@zendesk.com"
  config.password = 123456
  config.url = "http://dev.localhost:3000/api/v2/"
  config.log = true
  config.retry = true
end


user = client.users.first
ticket = Zendesk::Ticket.new(client, :ticket => { :type => "question",
                             :subject => "New ticket",
                             :description => "Blergh",
                             :priority => "normal",
                             :requester_id => user.id,
                             :submitter_id => user.id })
#ticket = client.tickets.first
ticket.uploads << "img.jpg"
ticket.save
debugger
true

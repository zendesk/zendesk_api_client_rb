#!/usr/bin/env bundle exec ruby
require 'zendesk'

client = Zendesk.configure do |config|
  config.username = "agent@zendesk.com"
  config.password = 123456
  config.url = "http://dev.localhost:3000/api/v2/"
  config.log = true
  config.retry = true
end

tickets = client.tickets.recent
show_many = client.topics.show_many(:verb => :post, :ids => [22,2])
puts client.topics
puts show_many.to_a

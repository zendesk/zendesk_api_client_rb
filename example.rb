#!/usr/bin/env bundle exec ruby
require 'zendesk'

client = Zendesk.configure do |config|
  config.username = "sdavidovitz@zendesk.com"
  config.password = "F5r5o5d5o5$"
  config.url = "https://smersh.zendesk.com/api/v2/"
  config.log = true
  config.retry = true
end

puts client.search(:query => "sdavidovitz@zendesk.com").to_a

#!/usr/bin/env bundle exec ruby
require 'zendesk'

client = Zendesk.configure do |config|
  config.username = "please.change"
  config.password = "me"
  config.url = "https://my.zendesk.com/api/v2/"
  config.log = true
  config.retry = true
end

puts client.current_account.inspect

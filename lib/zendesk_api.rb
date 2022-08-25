module ZendeskAPI; end

# TODO: REMOVE, I like debugging like this
require 'pry'
require 'pry-nav'

require 'faraday'
require 'faraday/multipart'

require 'zendesk_api/core_ext/inflection'
require 'zendesk_api/client'

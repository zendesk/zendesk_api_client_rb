module ZendeskAPI; end
require "pry"
require "pry-nav"

require 'faraday'

# TODO? what about other clients?
# we should probably support them, or it's not clear why we have faraday in the first place
require 'faraday/net_http_persistent'

require 'zendesk_api/core_ext/inflection'
require 'zendesk_api/client'

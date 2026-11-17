module ZendeskAPI; end

require "faraday"
require "faraday/multipart"

require_relative "zendesk_api/helpers"
require_relative "zendesk_api/core_ext/inflection"
require_relative "zendesk_api/client"
require_relative "zendesk_api/token_refresher"

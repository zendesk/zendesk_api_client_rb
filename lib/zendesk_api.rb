module ZendeskAPI; end

require "faraday"
require "faraday/multipart"

require "zendesk_api/helpers"
require "zendesk_api/core_ext/inflection"
require "zendesk_api/client"

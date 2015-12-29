module ZendeskAPI
  module Voice
    include DataNamespace
    self.namespace = 'voice'
  end
end

require 'zendesk_api/resources/voice/address'
require 'zendesk_api/resources/voice/agent'
require 'zendesk_api/resources/voice/greeting'
require 'zendesk_api/resources/voice/greeting_category'
require 'zendesk_api/resources/voice/phone_number'
require 'zendesk_api/resources/voice/ticket'

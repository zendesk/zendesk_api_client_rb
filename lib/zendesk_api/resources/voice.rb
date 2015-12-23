module ZendeskAPI
  module Voice
    include DataNamespace
    self.namespace = 'voice'
  end
end

require_relative 'voice/address'
require_relative 'voice/phone_number'
require_relative 'voice/greeting'
require_relative 'voice/greeting_category'

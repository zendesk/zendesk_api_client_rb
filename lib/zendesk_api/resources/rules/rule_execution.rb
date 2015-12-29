module ZendeskAPI
  class RuleExecution < Data
    has_many :custom_fields, class: 'TicketField'
  end
end

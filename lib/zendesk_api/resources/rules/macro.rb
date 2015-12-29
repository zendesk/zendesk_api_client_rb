require_relative 'rule'
require_relative 'actions'

module ZendeskAPI
  class Macro < Rule
    include Actions

    self.resource_name = 'macros'
    self.singular_resource_name = 'macro'

    has :execution, class: 'RuleExecution'

    # Returns the update to a ticket that happens when a macro will be applied.
    # @param [Ticket] ticket Optional {Ticket} to apply this macro to.
    # @raise [Faraday::Error::ClientError] Raised for any non-200 response.
    def apply!(ticket = nil)
      path = "#{self.path}/apply"

      if ticket
        path = "#{ticket.path}/#{path}"
      end

      response = @client.connection.get(path)
      Hashie::Mash.new(response.body.fetch("result", {}))
    end

    # Returns the update to a ticket that happens when a macro will be applied.
    # @param [Ticket] ticket Optional {Ticket} to apply this macro to
    def apply(ticket = nil)
      apply!(ticket)
    rescue Faraday::Error::ClientError => e
      Hashie::Mash.new
    end
  end
end

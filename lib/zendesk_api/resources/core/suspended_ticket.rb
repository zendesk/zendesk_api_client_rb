module ZendeskAPI
  class SuspendedTicket < ReadResource
    include Destroy

    # Recovers this suspended ticket to an actual ticket
    put :recover
  end
end

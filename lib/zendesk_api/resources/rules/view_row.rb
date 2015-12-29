module ZendeskAPI
  class ViewRow < DataResource
    has :ticket, class: Ticket

    # @internal Optional columns

    has :group, class: 'Group'
    has :assignee, class: 'User'
    has :requester, class: 'User'
    has :submitter, class: 'User'
    has :organization, class: 'Organization'

    def self.model_key
      "rows"
    end
  end
end

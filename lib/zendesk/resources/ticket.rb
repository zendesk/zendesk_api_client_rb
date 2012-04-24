module Zendesk
  class Ticket < Resource
    has :submitter, :class => :user
    has :assignee, :class => :user
    has :recipient, :class => :user
    has_many :collaborators, :class => :user
    has :group
    has :forum_topic, :class => :topic
    has :organization

    allow_parameters :ticket => [:external_id, :type, :subject, :priority, :status, :requester_id, :fields,
      :assignee_id, :group_id, :collaborator_ids, :forum_topic_id, :problem_id, :due_at, :tags, :description],
      :only => [:post, :put]
    allow_parameters :ticket => :submitter_id, :only => :post
  end

  class TicketField < Resource
    allow_parameters :ticket_field => [:type, :title, :description, :position, :is_active,
      :required, :collapsed_for_agents, :regexp_for_validation, :title_in_portal,
      :is_visible_in_portal, :is_editable_in_portal, :is_required_in_portal, :tag]
  end

  class View < DataResource
    # Owner => { id, type }
    # But if account, what to do?
  end
end

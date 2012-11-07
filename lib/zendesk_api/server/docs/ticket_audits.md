## Ticket Audits

Audits are a **read-only** history of all updates to a ticket and the events that occur as a result of these updates.  When a Ticket is updated in Zendesk, we store an Audit.  Each Audit represents a single update to the Ticket, and each Audit includes a list of changes, such as:

* Changes to ticket fields
* Addition of a new comment
* Addition or removal of tags
* Notifications sent to Groups, Assignees, Requesters and CCs

To learn more about adding new comments to tickets, [see our Ticket documentation](tickets.html#updating-tickets).

@import app/presenters/api/v2/tickets/audit_presenter.rb

@import app/controllers/api/v2/audits_controller.rb

### The Via Object

@import app/presenters/api/v2/tickets/event_via_presenter.rb

### Audit Events

An Audit contains many Events.  These Events represent all activity which occurs on a Ticket, including public and private Comments, field changes, notifications send by business rule execution, and events which send notification to external services via our Targets framework.

If an Event has a different Via than its Audit, it will have its own Via object.

@import app/presenters/api/v2/tickets/comment_presenter.rb

@import app/presenters/api/v2/tickets/voice_comment_presenter.rb

@import app/presenters/api/v2/tickets/comment_privacy_change_presenter.rb

@import app/presenters/api/v2/tickets/create_presenter.rb

@import app/presenters/api/v2/tickets/change_presenter.rb

@import app/presenters/api/v2/tickets/notification_presenter.rb

@import app/presenters/api/v2/tickets/cc_presenter.rb

@import app/presenters/api/v2/tickets/error_presenter.rb

@import app/presenters/api/v2/tickets/external_presenter.rb

@import app/presenters/api/v2/tickets/facebook_event_presenter.rb

@import app/presenters/api/v2/tickets/log_me_in_transcript_presenter.rb

@import app/presenters/api/v2/tickets/push_presenter.rb

@import app/presenters/api/v2/tickets/satisfaction_rating_event_presenter.rb

@import app/presenters/api/v2/tickets/twitter_event_presenter.rb

@import app/presenters/api/v2/tickets/sms_event_presenter.rb

@import app/presenters/api/v2/tickets/ticket_sharing_event_presenter.rb

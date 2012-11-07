## Incremental Tickets

The incremental ticket API is designed for API consumers that want to know about tickets that changed in Zendesk "since you last asked".  It works something like this:

```
You: Hello Zendesk, give me the tickets since 0 o'clock
Us: Sure, here are the tickets up until, and including, 5 o'clock
You: Hello Zendesk, give me the tickets since 5 o'clock
Us: Sure, here are the tickets up until, and including, 7 o'clock
```

Because of this API behavior, the incremental ticket API is different in behavior, requirements and semantics than other API endpoints.  Most important to note is that **the ticket response returns a lightweight representation of each ticket and does not include comments**.  To retrieve the full ticket response, use our [Tickets API](tickets.html) to retrieve the full ticket.

Please study the docs below and the data you get in response.

@import app/presenters/api/v2/exports/ticket_presenter.rb

@import app/controllers/api/v2/exports/tickets_controller.rb

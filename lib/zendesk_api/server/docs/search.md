## Search

The search API is a unified search API that returns tickets, users, organizations, and forum topics.  Define filters to narrow your search results according to result type, date attributes, and object attributes such as ticket requester or tag.

### A few example queries

| Search query                                                 | Returns...
| ------------------------------------------------------------ | ----------
| status<solved requester:user@domain.com type:ticket          | All unsolved tickets requested by user@domain.com
| type:user tags:premium_support                               | All users tagged with ``premium_support``
| created>2012-06-17 type:ticket organization:"Mondocam Photo" | Tickets created within the Mondocam Photo organization after July 17, 2012

Our [search reference](https://support.zendesk.com/entries/20239737-zendesk-search-reference) offers a complete guide to all search filters available for advanced search.

@import app/presenters/api/v2/search/results_presenter.rb

@import app/controllers/api/v2/search_controller.rb

@import app/presenters/api/v2/search/errors_presenter.rb

@import app/controllers/api/v2/portal/search_controller.rb

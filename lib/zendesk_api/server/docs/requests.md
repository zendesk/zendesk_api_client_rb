## Requests

A request is an end-users perspective on a ticket, this API end point is thus for end-users to view, update and create tickets they have access to. End-users can only see public comments and certain fields of a ticket, and you should use the API token to impersonate an end-user when using this end point.

@import app/presenters/api/v2/request_presenter.rb

@import app/presenters/api/v2/requests/comment_presenter.rb

@import app/controllers/api/v2/requests_controller.rb

@import app/controllers/api/v2/requests/comments_controller.rb

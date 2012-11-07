## Users

Zendesk has three main types of users: End-users (your customers), Agents and Administrators.

#### End-users

End-users request support via Tickets.  End-users have access to the Zendesk end-user portal where they can view forum content, access their ticket history, and submit new Tickets.

#### Agents

Agents work in Zendesk to solve Tickets. Agents can be divided into multiple Groups and can also belong to multiple Groups. Agents do not have access to administrative configuration in Zendesk such as business rules or automations, but can configure their own Macros and Views.

#### Administrators

Administrators have all the abilities of Agents, plus administrative abilities.  Accounts on the Enterprise plan can configure custom roles to give Agents varying degrees of administrative access.

### Show Requested Tickets, CCed Tickets and Topics for a User

See our Tickets API to retrieve [tickets requested by a User](tickets.html#listing-tickets), [tickets on which a user is CCed](tickets.html#listing-tickets).

See our Topics API to retrieve [topics created by a User](topics.html#list-topics) and [topic comments from a User](topic_comments.html#list-topic-comments).

@import app/presenters/api/v2/user_presenter.rb

@import app/controllers/api/v2/users_controller.rb

@import app/controllers/api/v2/current_user_controller.rb

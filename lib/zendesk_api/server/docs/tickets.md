## Tickets

Tickets are the means through which your End-users (customers) communicate with Agents in Zendesk.  Tickets can originate via a number of support channels: email, web portal, chat, phone call, Twitter, Facebook and the API. All tickets have a core set of properties.  Some key things to know are:

#### Requester

Every ticket has a Requester, Group and Assignee. The User who is asking for support through a ticket is the Requester.  For most businesses that use Zendesk, the Requester is a customer, but Requesters can also be agents in your Zendesk.

#### Submitter

The Submitter is the User who created a ticket.  If a Requester creates a ticket themselves, they are also the Submitter.  If an agent creates a ticket through the web interface, the agent is set as the Submitter.

#### Collaborators

Aside from the Requester, a Ticket can include other people in its communication, known as Collaborators or CCs.  Collaborators receive email notifications when tickets are updated.  Collaborators can be either End-users or Agents.

#### Group

The Group that a Ticket is assigned to.

#### Assignee

The agent, within a Group, who is assigned to a Ticket.  A Ticket can only be assigned to a single agent at a time.

#### Status

All tickets in Zendesk start out as New and progress through Open, Pending, Solved and Closed states.  A Ticket must have an Assignee in order to be solved.

@import app/presenters/api/v2/tickets/ticket_presenter.rb

@import app/controllers/api/v2/tickets_controller.rb

@import app/controllers/api/v2/collaborators_controller.rb

@import app/controllers/api/v2/incidents_controller.rb

@import app/controllers/api/v2/problems_controller.rb

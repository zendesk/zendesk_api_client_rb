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

### JSON Format
Tickets are represented as JSON objects which have the following keys:

| Name                  | Type                                     | Read-only | Mandatory | Comment
| --------------------- | ---------------------------------------- | --------- | --------- | -------
| id                    | integer                                  | yes       | no        | Automatically assigned when creating tickets
| url                   | string                                   | yes       | no        | The API url of this ticket
| external_id           | string                                   | no        | no        | A unique external id, you can use this to link Zendesk tickets to local records
| type                  | string                                   | no        | no        | The type of this ticket, i.e. "problem", "incident", "question" or "task"
| subject               | string                                   | no        | no        | The value of the subject field for this ticket
| description           | string                                   | yes       | no        | The first comment on the ticket
| priority              | string                                   | no        | no        | Priority, defines the urgency with which the ticket should be addressed: "urgent", "high", "normal", "low"
| status                | string                                   | no        | no        | The state of the ticket, "new", "open", "pending", "hold", "solved", "closed"
| recipient             | string                                   | yes       | no        | The original recipient e-mail address of the ticket
| requester_id          | integer                                  | no        | yes       | The user who requested this ticket
| submitter_id          | integer                                  | yes       | no        | The user who submitted the ticket; this is the currently authenticated API user
| assignee_id           | integer                                  | no        | no        | What agent is currently assigned to the ticket
| organization_id       | integer                                  | yes       | no        | The organization of the requester
| group_id              | integer                                  | no        | no        | The group this ticket is assigned to
| collaborator_ids      | array                                    | no        | no        | Who are currently CC'ed on the ticket
| forum_topic_id        | integer                                  | no        | no        | The topic this ticket originated from, if any
| problem_id            | integer                                  | no        | no        | The problem this incident is linked to, if any
| has_incidents         | boolean                                  | yes       | no        | Is true of this ticket has been marked as a problem, false otherwise
| due_at                | date                                     | no        | no        | If this is a ticket of type "task" it has a due date.  Due date format uses [ISO 8601](http://en.wikipedia.org/wiki/ISO_8601) format.
| tags                  | array                                    | no        | no        | The array of tags applied to this ticket
| via                   | [Via](ticket_audits.html#the-via-object) | yes       | no        | This object explains how the ticket was created
| custom_fields         | array                                    | no        | no        | The custom fields of the ticket
| satisfaction_rating   | object                                   | yes       | no        | The satisfaction rating of the ticket, if it exists
| sharing_agreement_ids | array                                    | yes       | no        | The ids of the sharing agreements used for this ticket
| created_at            | date                                     | yes       | no        | When this record was created
| updated_at            | date                                     | yes       | no        | When this record last got updated

#### Example
```js
{
  "id":               35436,
  "url":              "https://company.zendesk.com/api/v2/tickets/35436.json",
  "external_id":      "ahg35h3jh",
  "created_at":       "2009-07-20T22:55:29Z",
  "updated_at":       "2011-05-05T10:38:52Z",
  "type":             "incident",
  "subject":          "Help, my printer is on fire!",
  "description":      "The fire is very colorful.",
  "priority":         "high",
  "status":           "open",
  "recipient":        "support@company.com",
  "requester_id":     20978392,
  "submitter_id":     76872,
  "assignee_id":      235323,
  "organization_id":  509974,
  "group_id":         98738,
  "collaborator_ids": [35334, 234],
  "forum_topic_id":   72648221,
  "problem_id":       9873764,
  "has_incidents":    false,
  "due_at":           null,
  "tags":             ["enterprise", "other_tag"],
  "via": {
    "channel": "web"
  },
  "custom_fields": [
    {
      "id":    27642,
      "value": "745"
    },
    {
      "id":    27648,
      "value": "yes"
    }
  ],
  "satisfaction_rating": {
    "score": "good",
    "comment": "Great support!"
  },
  "sharing_agreement_ids": [84432]
}
```

### Listing Tickets
`GET /api/v2/tickets.json`

Tickets are ordered chronologically by created date, from oldest to newest.

#### Allowed for

 * Admins

`GET /api/v2/organizations/{organization_id}/tickets.json`

`GET /api/v2/users/{user_id}/tickets/requested.json`

`GET /api/v2/users/{user_id}/tickets/ccd.json`

`GET /api/v2/tickets/recent.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "tickets": [
    {
      "id":      35436,
      "subject": "Help I need somebody!",
      ...
    },
    {
      "id":      20057623,
      "subject": "Not just anybody!",
      ...
    },
  ]
}
```

### Getting Tickets
`GET /api/v2/tickets/{id}.json`

#### Allowed For

 * Agents

#### Using curl:

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "ticket": {
    {
      "id":      35436,
      "subject": "My printer is on fire!",
      ...
    }
  }
}
```

### Show Multiple Tickets
`POST /api/v2/tickets/show_many?ids={ids}.json`

Accepts a comma separated list of ticket ids to return.

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/show_many.json?ids={id,id,id} \
  -v -u {email_address}:{password} -X POST
```

#### Example Response

See [Listing Tickets](#example-response)

### Creating Tickets
`POST /api/v2/tickets.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets.json \
  -d '{"ticket":{"subject":"My printer is on fire!", "comment": { "body": "The smoke is very colorful." }}}' \
  -H "Content-Type: application/json" -v -u {email_address}:{password} -X POST
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/tickets/{id}.json

{
  "ticket": {
    {
      "id":      35436,
      "subject": "My printer is on fire!",
      ...
    }
  }
}
```

#### Request parameters

The POST request takes one parameter, a `ticket` object that lists the values to set when the ticket is created.

| Name                   | Description                                          |
| --------               | ---------------------------------------------------- |
| subject                | Required. The subject of the ticket. |
| comment                | Required. A comment object that describes the problem, incident, question, or task. See [Ticket comments](http://developer.zendesk.com/documentation/rest_api/ticket_audits.html#audit-events) in Audit Events. |
| requester\_id          | The numeric ID of the user asking for support through the ticket. |
| submitter\_id          | The numeric ID of the user submitting the ticket. |
| assignee\_id           | The numeric ID of the agent to assign the ticket to. |
| group\_id              | The numeric ID of the group to assign the ticket to. |
| collaborator\_ids      | An array of the numeric IDs of agents or end-users to CC on the ticket. An email notification is sent to them when the ticket is created. |
| type                   | Allowed values are `problem`, `incident`, `question`, or `task`. |
| priority               | Allowed values are `urgent`, `high`, `normal`, or `low`. |
| status                 | Allowed values are `new`, `open`, `pending`, `hold`, `solved` or `closed`. Is set to `open` if status is not specified. |
| tags                   | An array of tags to add to the ticket. |
| external\_id           | A unique external ID to link Zendesk tickets to local records. |
| forum\_topic\_id       | The numeric ID of the topic the ticket originated from, if any. |
| problem\_id            | For tickets of type "incident", the numeric ID of the problem the incident is linked to, if any. |
| due\_at                | For tickets of type "task", the due date of the task. Accepts the ISO 8601 date format (yyyy-mm-dd). |
| custom\_fields         | An array of the custom fields of the ticket. |

#### Example request

```js
"ticket":{
 "subject":"My printer is on fire!",
 "comment": { "body": "The smoke is very colorful." },
 "priority": "urgent"
}
```

### Updating Tickets
`PUT /api/v2/tickets/{id}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{id}.json \
  -H "Content-Type: application/json" \
  -d '{"ticket":{"status":"solved",   \
       "comment":{"public":true, "body": "Thanks, this is now solved!"}}}' \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response

```http
Status: 200 OK

{
  "ticket": {
     "id":      35436,
     "subject": "My printer is on fire!",
     "status":  "solved",
     ...
  },
  "audit": {
     "events": [...],
     ...
  }
}
```

#### Request parameters

The PUT request takes one parameter, a `ticket` object that lists the values to update. All properties are optional.

| Name                   | Description                                          |
| --------               | ---------------------------------------------------- |
| subject                | The subject of the ticket. |
| comment                | An object that adds a comment to the ticket. See [Ticket comments](http://developer.zendesk.com/documentation/rest_api/ticket_audits.html#audit-events) in Audit Events. |
| requester\_id          | The numeric ID of the user asking for support through the ticket. |
| assignee\_id           | The numeric ID of the agent to assign the ticket to. |
| group\_id              | The numeric ID of the group to assign the ticket to. |
| collaborator\_ids      | An array of the numeric IDs of agents or end-users to CC. Note that this replaces any existing collaborators. An email notification is sent to them when the ticket is created. |
| type                   | Allowed values are `problem`, `incident`, `question`, or `task`. |
| priority               | Allowed values are `urgent`, `high`, `normal`, or `low`. |
| status                 | Allowed values are `open`, `pending`, `hold`, `solved` or `closed`. |
| tags                   | An array of tags to add to the ticket. Note that the tags replace any existing tags. |
| external\_id           | A unique external ID to link Zendesk tickets to local records. |
| forum\_topic\_id       | The numeric ID of the topic the ticket originated from, if any. |
| problem\_id            | For tickets of type "incident", the numeric ID of the problem the incident is linked to, if any. |
| due\_at                | For tickets of type "task", the due date of the task. Accepts the ISO 8601 date format (yyyy-mm-dd). |
| custom\_fields         | An array of the custom field objects consisting of ids and values. Any tags defined with the custom field replace existing tags.  |

#### Example request

```js
"ticket": {
 "comment":{ "body": "Thanks for choosing Acme Jet Motors.", "public":"true" },
 "status": "solved"
}
```

### Bulk Updating Tickets
`PUT /api/v2/tickets/update_many.json?ids={ids}`

#### Allowed For

 * Agents

#### Example Request

```js
"ticket": {
  "status": "solved"
}
```

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/update_many.json?ids=1,2,3 \
  -H "Content-Type: application/json" -d "{\"ticket\":{\"status\":\"solved\"}}" \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response

See [Job Status](job_statuses.md#show-job-status)

### Mark a ticket as spam and suspend the requester
`PUT /api/v2/tickets/{id}/mark_as_spam.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{id}/mark_as_spam.json\
  -v -u {email_address}:{password} -X PUT
```

#### Example Response

```http
Status: 200 OK
```

### Setting Collaborators

You can set collaborators on tickets by passing in an array identifying the collaboratos you wish to
set. Each slot in the array is either the id of a user or the email address of a user or a hash containing
user name and email.

* `someone@example.com`
* `{ "name": "Someone Special", "email": "someone@example.com" }`

You can use the latter for also specifying the name of a collaborator such that the user gets created
on the fly with the appropriate name.

#### Example Request

```js
"ticket": {
  "collaborators": [ 562, "someone@example.com", { "name": "Someone Else", "email": "else@example.com" } ]
}
```

Note that setting collaborators this way will completely ignore what's already set, so make sure to
include existing collaborators in the array if you wish to retain these on the ticket.

### Setting Metadata

When you create or update a ticket, an [Audit](ticket_audits.md) gets generated if the ticket properties have changed.
On each such audit, you can add up to 1 kilobyte of custom metadata. You can use this to build your own integrations or apps.
**Note**: If your update does not change the ticket, this will not create an Audit and will not save your metadata.

#### Example Request

```js
"ticket": {
  "metadata": { "time_spent": "4m12s", "account": "integrations" },
  "comment":  { "body": "Please press play on tape now" },
  "status":   "pending"
}
```

Note that metadata can only be set as part of other regular ticket updates as they are associated to a such
rather than just the ticket. Zendesk also adds metadata on each ticket update, and the resulting audit JSON
structure looks like this:

```js
"audit": {
{
  "id":         35436,
  "ticket_id":  47,
  "created_at": "2012-04-20T22:55:29Z",
  "author_id":  35436,
  "metadata":  {
    "custom": {
      "time_spent": "4m12s",
      "account": "integrations"
    },
    "system": {
      "ip_address": "184.106.40.75",
      "location": "United States",
      "longitude": -97,
      "latitude": 38,
      "client": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3)"
    }
  },
  "via": {
    "channel": "web"
  },
  "events": [
    {
      "id":          1564245,
      "type":        "Comment"
      "body":        "Please press play on tape now",
      "public":      true,
      "attachments": []
    },
    ...
  ]
}
}
```

### Attaching Files

When creating and updating tickets you may attach files by passing in
an array of the tokens received from uploading the files. For the upload attachment
to succeed when updating a ticket, a comment must be included.

To get the token of upload, see [Attachments](attachments.md) section on uploading files.

The upload tokens are single use only.  After a token is used to attach a file to a ticket comment,
that token cannot be used to attach the same upload to an additional ticket comment.

#### Example Request

```js
"ticket": {
  "comment":  { "body": "Please press play on tape now", "uploads":  ["vz7ll9ud8oofowy"] }
}
```

### Creating a Ticket with a new Requester

Requesters can explicitly be created handling tickets.
The name, email, and locale id can be set on the new requester, with the name and email being required.

To get the locale id, see the [Locales](locales.md) section.

#### Example Request

```js
"ticket": {
  "subject": "Hello",
  "comment": { "body": "Some question" },
  "requester": { "locale_id": 8, "name": "Pablo", "email": "pablito@example.org" }
}
```

Please note, if a user already exists with the given email address then we will use that user,
no updates will be made to existing users during the ticket create process. In this approach, only the email attribute is required.

### Setting Ticket Fields

When creating or updating a ticket, [Ticket Fields](ticket_fields.md) can be set by passing in
an array of objects in the format { id: {id}, value: {value} }.

#### Example Request

```js
"ticket": {
  "subject": "Hello",
  "comment": { "body": "Some question" },
  "custom_fields": [{ "id": 34, "value": "I need help!" }]
}
```

### Deleting Tickets
`DELETE /api/v2/tickets/{id}.json`

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{id}.json \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```

### Bulk Deleting Tickets
`DELETE /api/v2/tickets/destroy_many.json?ids={ids}`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/destroy_many.json?ids=1,2,3 \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```

### List Collaborators for a Ticket
`GET /api/v2/tickets/{id}/collaborators.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{id}/collaborators.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200

{
  "users": [
    {
      "id": 223443,
      "name": "Johnny Agent",
      ...
    },
    {
      "id": 8678530,
      "name": "Peter Admin",
      ...
    }
  ]
}
```

### Listing Ticket Incidents
`GET /api/v2/tickets/{id}/incidents.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/12345/incidents.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "tickets": [
    {
      "id":          33,
      "subject":     "My printer is on fire",
      "description": "The fire is very colorful.",
      "status":      "open",
      ...
    },
    {
      "id":          34,
      "subject":     "The printer is on fire over here too",
      "description": "The fire is very colorful as well!",
      "status":      "pending",
      ...
    },
  ]
}
```

### Listing Ticket Problems
`GET /api/v2/problems.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/problems.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "tickets": [
    {
      "id":          33,
      "subject":     "My printer is on fire",
      "description": "The fire is very colorful.",
      "status":      "open",
      ...
    },
    {
      "id":          34,
      "subject":     "The printer is on fire over here too",
      "description": "The fire is very colorful as well!",
      "status":      "pending",
      ...
    },
  ]
}
```

### Autocomplete Problems
`POST /api/v2/problems/autocomplete.json?text={name}`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/problems/autocomplete.json \
  -X POST -d '{"text": "att"}' -H "Content-Type: application/json" \
  -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "tickets": [
    { .. ticket record as in the #index method .. },
    { .. ticket record as in the #index method .. }
  ]
}
```
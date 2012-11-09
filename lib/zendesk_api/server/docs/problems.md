## Problems

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
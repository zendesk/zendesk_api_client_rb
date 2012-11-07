## Ticket Metrics

### JSON Format

| Name                               | Type                   | Read-only | Mandatory | Comment
| ---------------------------------- | ---------------------- | --------- | --------- | -------
| id                                 | integer                | yes       | no        | Automatically assigned
| ticket_id                          | integer                | yes       | no        | Id of the associated ticket
| url                                | string                 | yes       | no        | The API url of this ticket metric
| group_stations                     | integer                | yes       | no        | Number of groups this ticket passed through
| assignee_stations                  | integer                | yes       | no        | Number of assignees this ticket had
| reopens                            | integer                | yes       | no        | Total number of times the ticket was reopened
| replies                            | integer                | yes       | no        | Total number of times ticket was replied to
| assignee_updated_at                | date                   | yes       | no        | When the assignee last updated the ticket
| requester_updated_at               | date                   | yes       | no        | When the requester last updated the ticket
| status_updated_at                  | date                   | yes       | no        | When the status was last updated
| initially_assigned_at              | date                   | yes       | no        | When the ticket was initially assigned
| assigned_at                        | date                   | yes       | no        | When the ticket was last assigned
| solved_at                          | date                   | yes       | no        | When the ticket was solved
| latest_comment_added_at            | date                   | yes       | no        | When the latest comment was added
| first_resolution_time_in_minutes   | object                 | yes       | no        | Number of minutes to the first resolution time inside and out of business hours
| reply_time_in_minutes              | object                 | yes       | no        | Number of minutes to the first reply inside and out of business hours
| full_resolution_time_in_minutes    | object                 | yes       | no        | Number of minutes to the full resolution inside and out of business hours
| agent_wait_time_in_minutes         | object                 | yes       | no        | Number of minutes the agent spent waiting inside and out of business hours
| requester_wait_time_in_minutes     | object                 | yes       | no        | Number of minutes the requester spent waiting inside and out of business hours
| created_at                         | date                   | yes       | no        | When this record was created
| updated_at                         | date                   | yes       | no        | When this record last got updated

#### Example
```js
  { "id": 33,
    "ticket_id": 4343,
    "created_at": "2009-07-20T22:55:29Z",
    "updated_at": "2011-05-05T10:38:52Z",
    "group_stations": 7,
    "assignee_stations": 1,
    "reopens": 55,
    "replies": 322,
    "assignee_updated_at": "2011-05-06T10:38:52Z",
    "requester_updated_at": "2011-05-07T10:38:52Z",
    "status_updated_at": "2011-05-04T10:38:52Z",
    "initially_assigned_at": "2011-05-03T10:38:52Z",
    "assigned_at": "2011-05-05T10:38:52Z",
    "solved_at": "2011-05-09T10:38:52Z",
    "latest_comment_added_at": "2011-05-09T10:38:52Z",
    "reply_time_in_minutes": { "calendar": 2391, "business": 737 },
    "first_resolution_time_in_minutes": { "calendar": 2391, "business": 737 },
    "full_resolution_time_in_minutes": { "calendar": 2391, "business": 737 },
    "agent_wait_time_in_minutes": { "calendar": 2391, "business": 737 },
    "requester_wait_time_in_minutes": { "calendar": 2391, "business": 737 },
    "on_hold_time_in_minutes": { "calendar": 2290, "business": 637 }
  }
```

### Listing Ticket Metrics
`GET /api/v2/ticket_metrics.json`

`GET /api/v2/tickets/{id}/metrics.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/ticket_metrics.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "ticket_metrics": [
    {
      "id": 33,
      "ticket_id": 4343,
      "reopens": 55,
      "replies": 322,
      ...
    }
    {
      "id": 34,
      "ticket_id": 443,
      "reopens": 123,
      "replies": 232,
      ...
    },
  ]
}
```

### Getting Ticket Metrics
`GET /api/v2/ticket_metrics/{id}.json`

#### Allowed For

 * Agents

#### Using curl:

```bash
curl https://{subdomain}.zendesk.com/api/v2/ticket_metrics/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "ticket_metric": {
    {
      "id": 34,
      "ticket_id": 443,
      "reopens": 123,
      "replies": 232,
      ...
    }
  }
}
```
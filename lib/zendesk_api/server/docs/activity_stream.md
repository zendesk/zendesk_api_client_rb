## Activity Stream

The **activity stream** is a per agent event stream. It will give access to the most recent events that relate to the agent polling the API.

### JSON Format
Ticket activity events are represented as JSON objects which have the following keys:

| Name             | Type                   | Read-only | Mandatory | Comment
| ---------------- | ---------------------- | --------- | --------- | -------
| id               | integer                | yes       | no        | Automatically assigned upon creation
| url              | string                 | yes       | no        | The API url of this activity
| title            | string                 | yes       | yes       | Description of this activity
| verb             | string                 | yes       | yes       | Identifies the type of the activity
| user             | [User](users.md)       | yes       | yes       | The user this activity pertains to
| actor            | [User](users.md)       | yes       | yes       | The actor causing the creation of the activity
| created_at       | date                   | yes       | no        | When this record was created
| updated_at       | date                   | yes       | no        | When this record last got updated
| object           | object                 | yes       | no        | The content of this activity. Can be a ticket, comment, or change.
| target           | object                 | yes       | no        | The target of this activity, a ticket.

#### Example
```js
{
  "id":          35,
  "url":         "https://company.zendesk.com/api/v2/activities/35.json",
  "verb":        "tickets.assignment",
  "title":       "John Hopeful assigned ticket #123 to you",
  "user":        { ... },
  "actor":       { ... },
  "created_at":  "2012-03-05T10:38:52Z",
  "updated_at":  "2012-03-05T10:38:52Z"
}
```

### List Activities
`GET /api/v2/activities.json`

#### Allowed For:

 * Agents

Lists activities pertaining to the user performing the request.

#### Request Parameters

You can pass an optional `since` parameter which designates a timestamp offset, and the API
will only return activities happening after that offset. The format of the `since` parameter
must be in UTC on ISO8601 form `%Y-%m-%dT%H:%M:%SZ`, e.g. `2012-04-03T16:02:46Z`

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/activities.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "activities": [
    {
      "id":          35,
      "url":         "https://company.zendesk.com/api/v2/activities/35.json",
      "verb":        "tickets.assignment",
      "title":       "John Hopeful assigned ticket #123 to you",
      "user":        { ... },
      "actor":       { ... },
      "created_at":  "2012-03-05T10:38:52Z",
      "updated_at":  "2012-03-05T10:38:52Z"
    },
    {
      "id":          45,
      "url":         "https://company.zendesk.com/api/v2/activities/45.json",
      "verb":        "tickets.comment",
      "title":       "John Hopeful commented in ticket #44",
      "user":        { ... },
      "actor":       { ... },
      "created_at":  "2012-03-05T11:32:44Z",
      "updated_at":  "2012-03-05T11:32:44Z"
    }
  ]
}
```

### Show Activity
`GET /api/v2/activities/{id}.json`

#### Allowed For:

 * Agent

Only provides access to an activities pertaining to the agent executing the request

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/activities/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "activity": {
    "id":          45,
    "url":         "https://company.zendesk.com/api/v2/activities/45.json",
    "verb":        "tickets.comment",
    "title":       "John Hopeful commented in ticket #44",
    "user":        { ... },
    "actor":       { ... },
    "created_at":  "2012-03-05T11:32:44Z",
    "updated_at":  "2012-03-05T11:32:44Z"
  }
}
```
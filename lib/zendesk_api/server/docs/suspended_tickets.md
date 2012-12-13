## Suspended Tickets


| Name             | Type                   | Read-only | Mandatory | Comment
| ---------------- | ---------------------- | --------- | --------- | -------
| id               | integer                | yes       | no        | Automatically assigned
| url              | string                 | yes       | no        | The API url of this ticket
| author           | object                 | yes       | no        | The author id (if available), name and email
| subject          | string                 | yes       | no        | The value of the subject field for this ticket
| content          | string                 | yes       | no        | The content that was flagged
| cause            | string                 | yes       | no        | Why the ticket was suspended
| message_id       | string                 | yes       | no        | The ID of the email, if available
| ticket_id        | integer                | yes       | no        | The ticket ID this suspended email is associated with, if available
| created_at       | date                   | yes       | no        | When this record was created
| updated_at       | date                   | yes       | no        | When this record last got updated
| via              | [Via](#the-via-object) | yes       | no        | This object explains how the ticket was created

#### Example
```js
{
  "id":               435,
  "url":              "https://example.zendesk.com/api/v2/tickets/35436.json",
  "author":           { "id": 1, "name": "Mr. Roboto", "email": "styx@example.com" },
  "subject":          "Help, my printer is on fire!",
  "content":          "Out Of Office Reply",
  "cause":            "Detected as spam",
  "ticket_id":        67321,
  "created_at":       "2009-07-20T22:55:29Z",
  "updated_at":       "2011-05-05T10:38:52Z",
  "via": {
    "channel": "web"
  }
}
```

### Listing Suspended Tickets
`GET /api/v2/suspended_tickets.json`

#### Allowed For

 * Unrestricted Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/suspended_tickets.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "suspended_tickets": [
    {
      "id":      3436,
      "subject": "Help I need somebody!",
      "cause":   "Detected as spam",
      ...
    },
    {
      "id":      207623,
      "subject": "Not just anybody!",
      "cause":   "Automated response mail",
      ...
    },
  ]
}
```

### Getting Suspended Tickets
`GET /api/v2/suspended_tickets/{id}.json`

#### Allowed For

 * Unrestricted Agents

#### Using curl:

```bash
curl https://{subdomain}.zendesk.com/api/v2/suspended_tickets/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "suspended_ticket": {
    {
      "id":      35436,
      "subject": "My printer is on fire!",
      "cause":   "Automated response mail",
      ...
    }
  }
}
```

### Recovering Suspended Tickets
`PUT /api/v2/suspended_tickets/{id}/recover.json`

#### Allowed For

 * Unrestricted Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/suspended_tickets/{id}/recover.json \
  -X PUT -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK
```

### Recovering Multiple Suspended Tickets
`PUT /api/v2/suspended_tickets/recover_many.json?ids={id1},{id2}`

Note: Suspended tickets that fail to be recovered will be included in the response.

#### Allowed For

 * Unrestricted Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/suspended_tickets/recover_many.json?ids={id1},{id2} \
  -H "Content-Type: application/json" -X PUT \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK
```

### Deleting Tickets
`DELETE /api/v2/suspended_tickets/{id}.json`

#### Allowed For

 * Unrestricted Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/suspended_tickets/{id}.json \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```

### Deleting Multiple Tickets
`DELETE /api/v2/suspended_tickets/destroy_many.json?ids={id1},{id2}`

#### Allowed For

 * Unrestricted Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/suspended_tickets/destroy_many.json?ids={id1},{id2} \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```
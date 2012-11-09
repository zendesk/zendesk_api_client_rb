## Requests

A request is an end-users perspective on a ticket, this API end point is thus for end-users to view, update and create tickets they have access to. End-users can only see public comments and certain fields of a ticket, and you should use the API token to impersonate an end-user when using this end point.

### JSON Format
Requests are represented as JSON objects which have the following keys:

| Name             | Type                                     | Read-only | Mandatory | Comment
| ---------------- | ---------------------------------------- | --------- | --------- | -------
| id               | integer                                  | yes       | no        | Automatically assigned when creating requests
| url              | string                                   | yes       | no        | The API url of this request
| subject          | string                                   | no        | no        | The value of the subject field for this request
| description      | string                                   | yes       | no        | The first comment on the request
| status           | string                                   | no        | no        | The state of the request, "new", "open", "pending", "hold", "solved", "closed"
| custom_fields    | Array                                    | no        | no        | The fields and entries for this request
| organization_id  | integer                                  | yes       | no        | The organization of the requester
| via              | [Via](ticket_audits.html#the-via-object) | yes       | no        | This object explains how the request was created
| created_at       | date                                     | yes       | no        | When this record was created
| updated_at       | date                                     | yes       | no        | When this record last got updated

#### Example
```js
{
  "id":               35436,
  "url":              "https://company.zendesk.com/api/v2/requests/35436.json",
  "created_at":       "2009-07-20T22:55:29Z",
  "updated_at":       "2011-05-05T10:38:52Z",
  "subject":          "Help, my printer is on fire!",
  "description":      "The fire is very colorful.",
  "status":           "open",
  "organization_id":  509974,
  "via": {
    "channel": "web"
  }
}
```

#### Request Comments
Comments represent the public conversation between Requesters, Collaborators and Agents on a request.

Ticket comments have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| body            | string  | yes       | The actual comment made by the author
| attachments     | array   | yes       | The attachments on this comment as [Attachment](attachments.md) objects
| created_at      | date    | yes       | When this comment was created

#### Example
```js
{
  "id":     1274,
  "body":   "Thanks for your help!",
  "attachments": [
    {
      "id":           498483,
      "name":         "crash.log",
      "content_url":  "https://company.zendesk.com/attachments/crash.log",
      "content_type": "text/plain",
      "size":         2532,
      "thumbnails":   []
    }
  ],
 "created_at": "2009-07-20T22:55:29Z"
}
```

### Listing Requests
`GET /api/v2/requests.json`

`GET /api/v2/requests/open.json`

`GET /api/v2/requests/solved.json`

`GET /api/v2/requests/ccd.json`

`GET /api/v2/users/{id}/requests.json`

#### Allowed For

 * End Users

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/requests.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "requests": [
    {
      "id": 33,
      "status": "open",
      "description": "My printer is on fire!",
      ...
    }
    {
      "id": 34,
      "status": "closed",
      "description": "I can't find my keys",
      ...
    },
  ]
}
```

### Getting Requests
`GET /api/v2/requests/{id}.json`

#### Allowed For

 * End Users

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/requests/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "request": {
    "id": 33,
    "status": "open",
    "description": "My printer is on fire!",
    ...
  }
}
```

### Creating Requests
`POST /api/v2/requests.json`

#### Allowed For

 * End Users

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/requests.json \
  -d '{"request": {"subject": "Help!", "comment": {"body": "My printer is on fire!", "uploads": [...]}}}' \
  -v -u {email_address}:{password} -X POST -H "Content-Type: application/json"
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/requests/{id}.json

{
  "request": {
    "id": 33,
    "status": "new",
    "description": "My printer is on fire!",
    ...
  }
}
```

### Updating Requests
`PUT /api/v2/requests/{id}.json`

#### Allowed For

 * End Users

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/requests/{id}.json \
  -d '{"request": {"comment": {"body": "Thanks!"}}}' \
  -v -u {email_address}:{password} -X PUT -H "Content-Type: application/json"
```

#### Example Response
```http
Status: 200 OK

{
  "request": {
    "id": 33,
    "status": "new",
    "description": "My printer is on fire!",
    ...
  }
}
```

### Listing Comments
`GET /api/v2/requests/{id}/comments.json`

#### Allowed For

* End Users

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/requests/{id}/comments.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "comments": [
    {
      "id": 43,
      "body": "Thanks for your help!",
      ...
    },
    ...
  ]
}
```

### Getting Comments
`GET /api/v2/requests/{request_id}/comments/{id}.json`

#### Allowed For

* End Users

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/requests/{request_id}/comments/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "comment": {
    "id": 43,
    "body": "Thanks!",
    ...
  }
}
```
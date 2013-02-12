## Macros

A macro consists of one or more actions that modify the values of a ticket's fields. Macros are applied to tickets manually by agents. For example, you can create macros for support requests that agents can answer with a single, standard response. For more information, see [Using macros to update and add comments to tickets](https://support.zendesk.com/entries/20011363).

### JSON Format
Macros are represented as simple flat JSON objects which have the following keys.

| Name            | Type                       | Comment
| --------------- | ---------------------------| -------------------
| id              | integer                    | Automatically assigned when created
| title           | string                     | The title of the macro
| active          | boolean                    | Useful for determining if the macro should be displayed
| restriction     | object                     | Who may access this macro. Will be null when everyone in the account can access it.
| actions         | [Actions](#actions)        | An object describing what the macro will do
| created_at      | date                       | The time the macro was created
| updated_at      | date                       | The time of the last update of the macro

#### Example
```js
{
  "macro": {
    "id": 25,
    "title": "Tickets updated <12 Hours",
    "active": true,
    "actions": { ... },
    "restriction": {
      "type": "User",
      "id": 4
    }
  }
}
```

### Actions
The actions that will be applied to the ticket.

| Name         | Type    | Comment
| ------------ | ------- | -------
| field        | string  | The ticket field being modified
| value        | string  | The new value of the field

#### Example
```js
{
   "actions": [
       { "field": "status", "value": "solved" },
       { "field": "assignee", "value": "me" },
   ]
}
```

### List Macros
`GET /api/v2/macros.json`

Lists all shared and personal macros available to the current user

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/macros.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "macros": [
     {
      "id": 25,
      "title": "Close and Save",
      "active": true
      "actions": [ ... ],
      "restriction": { ... }
    },
    {
      "id": 26,
      "title": "Assign priority tag",
      "active": false
      "actions": [ ... ],
      "restriction": { ... }
    }
  ],
  "count": 2,
  "previous_page": null,
  "next_page": null
}
```

### Getting Macros
`GET /api/v2/macros/{id}.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/macros/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "macro": {
    "id": 25,
    "title": "Tickets updated <12 Hours",
    "active": true
    "actions": [ ... ],
    "restriction": { ... }
  }
}
```

### List active Macros
`GET /api/v2/macros/active.json`

Lists all active shared and personal macros available to the current user

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/macros/active.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "macros": [
     {
      "id": 25,
      "title": "Close and Save",
      "active": true
      "actions": [ ... ],
      "restriction": { ... }
    },
    {
      "id": 28,
      "title": "Close and redirect to topics",
      "active": true
      "actions": [ ... ],
      "restriction": { ... }
    }
  ],
  "count": 2,
  "previous_page": null,
  "next_page": null
}
```

### Create Macro
`POST /api/v2/macros.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/macros.json \
  -H "Content-Type: application/json" -X POST -d '{"macro": {"title": "Roger Wilco", "actions": [{ "field": "status", "value": "open" }]}}'
```

#### Example Response

```http
Status: 201 Created
Location: /api/v2/macros/{new-macro-id}.json

{
  "macro": {
    "id":   9873843,
    "title": "Roger Wilco",
    ...
  }
}
```

### Update Macro
`PUT /api/v2/macros/{id}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/macros/{id}.json \
  -H "Content-Type: application/json" -X PUT -d '{"macro": {"title": "Roger Wilco II"}}'
```

#### Example Response

```http
Status: 200 OK

{
  "macro": {
    "id":   9873843,
    "title": "Roger Wilco II",
    ...
  }
}
```

### Delete Macro
`DELETE /api/v2/macros/{id}.json`

#### Allowed For

 * Agents, restrictions apply on certain actions

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/macros/{id}.json \
  -X DELETE
```

#### Example Response

```http
Status: 200 OK
```

### Apply Macros
`GET /api/v2/macros/{id}/apply.json`

`GET /api/v2/tickets/{ticket_id}/macros/{id}/apply.json`

Applies a macro to a specific ticket, or to all applicable tickets.

#### Allowed For:

  * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{ticket_id}/macros/{id}/apply.json \
  -u {email_address}:{password}
```

#### Example Response

```json
{
  "result": {
    "ticket": {
      "id":               35436,
      "url":              "https://company.zendesk.com/api/v2/tickets/35436.json",
      "assignee_id":      235323,
      "group_id":         98738,
      "fields": [
        {
          "id":    27642,
          "value": "745"
        }
      ],
      ...
    },
    "comment": {
      "body": "Assigned to Agent Uno.",
      "public": false
    }
  }
}
```
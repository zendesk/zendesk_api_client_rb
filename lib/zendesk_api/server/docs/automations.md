## Automations

An automation consists of one or more actions that are performed if certain conditions are met after a period of time. The conditions are checked every hour. For example, an automation can notify an agent when a ticket remains unresolved after 24 hours.

Even if the actions are performed once, they'll be performed again later if the conditions still apply. To ensure the actions are performed only once, include an action in the automation that cancels one of the conditions.

For more information, see [Streamlining workflow with time-based events and automations](https://support.zendesk.com/entries/20012032).

### JSON Format
Automations are represented as simple flat JSON objects which have the following keys.

| Name            | Type                       | Comment
| --------------- | ---------------------------| -------------------
| id              | integer                    | Automatically assigned when created
| title           | string                     | The title of the trigger
| active          | boolean                    | Whether the trigger is active
| conditions      | [Conditions](#conditions)  | An object that describes the conditions under which the trigger will execute
| actions         | [Actions](#actions)        | An object describing what the trigger will do
| created_at      | date                       | The time the trigger was created
| updated_at      | date                       | The time of the last update of the trigger

#### Example
```js
{
  "automation": {
    "id": 25,
    "title": "Notify requester of comment update",
    "active": true,
    "actions": { ... },
    "conditions": { ... },
    "updated_at": "2012-09-25T22:50:26Z",
    "created_at": "2012-09-25T22:50:26Z"
  }
}
```

### Conditions
The conditions under which a ticket is selected.

| Name         | Type    | Comment
| ------------ | ------- | -------
| all          | array   | Tickets must fulfill *all* of these conditions to be considered matching
| any          | array   | Tickets may satisfy *any* of these conditions to be considered matching

#### Example
```js
{
   "conditions": {
     "all": [
       { "field": "status", "operator": "less_than", "value": "solved" },
       { "field": "assignee", "operator": "is", "value": "me" },
     ],
     "any": [
     ]
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

### List Automations
`GET /api/v2/automations.json`

Lists all automations for the current account

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/automations.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "automations": [
     {
      "id": 25,
      "title": "Close and Save",
      "active": true
      "conditions": [ ... ],
      "actions": [ ... ],
      ...
    },
    {
      "id": 26,
      "title": "Assign priority tag",
      "active": false
      "conditions": [ ... ],
      "actions": [ ... ],
      ...
    }
  ],
  "count": 2,
  "previous_page": null,
  "next_page": null
}
```

### Getting Automations
`GET /api/v2/automations/{id}.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/automations/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "automation": {
    "id": 25,
    "title": "Tickets updated <12 Hours",
    "active": true
    "conditions": [ ... ],
    "actions": [ ... ],
    ...
  }
}
```

### List active Automations
`GET /api/v2/automations/active.json`

Lists all active automations

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/automations/active.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "automations": [
     {
      "id": 25,
      "title": "Close and Save",
      "active": true
      "conditions": [ ... ],
      "actions": [ ... ],
      ...
    },
    {
      "id": 28,
      "title": "Close and redirect to topics",
      "active": true
      "conditions": [ ... ],
      "actions": [ ... ],
      ...
    }
  ],
  "count": 2,
  "previous_page": null,
  "next_page": null
}
```

### Create Automation
`POST /api/v2/automations.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/automations.json \
  -H "Content-Type: application/json" -X POST -d \
  '{"automation":{"title":"Roger Wilco", "all": [{ "field": "status", "operator": "is", "value": "open" }], "actions": [{ "field": "status", "value": "closed" }]}}'
```

#### Example Response

```http
Status: 201 Created
Location: /api/v2/automation/{new-automation-id}.json

{
  "automation": {
    "id":   9873843,
    "title": "Roger Wilco",
    ...
  }
}
```

### Update Automation
`PUT /api/v2/automations/{id}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/automations/{id}.json \
  -H "Content-Type: application/json" -X PUT -d '{"automation":{"title":"Roger Wilco II"}}'
```

#### Example Response

```http
Status: 200 OK

{
  "automation": {
    "id":   9873843,
    "title": "Roger Wilco II",
    ...
  }
}
```
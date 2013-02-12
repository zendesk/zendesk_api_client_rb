## Triggers

A trigger consists of one or more actions performed when a ticket is created or updated. The actions are performed only if certain conditions are met. For example, a trigger can notify the customer when an agent changes the status of a ticket to Solved.

All your triggers are checked from first to last each time a ticket is created or updated. The order of triggers is important because the actions of one trigger may affect another trigger. New triggers are added in last place by default.

For more information, see [Streamlining workflow with ticket updates and triggers](https://support.zendesk.com/entries/20011606).


### JSON Format
Triggers are represented as simple flat JSON objects which have the following keys.

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
  "trigger": {
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

### List Triggers
`GET /api/v2/triggers.json`

Lists all triggers for the current account

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/triggers.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "triggers": [
     {
      "url"=>"http://{subdomain}.zendesk.com/api/v2/triggers/25.json",
      "id": 25,
      "title": "Close and Save",
      "active": true
      "conditions": [ ... ],
      "actions": [ ... ],
      "updated_at": "2012-09-25T22:50:26Z",
      "created_at": "2012-09-25T22:50:26Z"
    },
    {
      "url"=>"http://{subdomain}.zendesk.com/api/v2/triggers/26.json",
      "id": 26,
      "title": "Assign priority tag",
      "active": false
      "conditions": [ ... ],
      "actions": [ ... ],
      "updated_at": "2012-09-25T22:50:26Z",
      "created_at": "2012-09-25T22:50:26Z"
    }
  ],
  "count": 2,
  "previous_page": null,
  "next_page": null
}
```

### Getting Triggers
`GET /api/v2/triggers/{id}.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/triggers/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "trigger": {
    "id": 25,
    "title": "Tickets updated <12 Hours",
    "active": true
    "conditions": [ ... ],
    "actions": [ ... ],
    "updated_at": "2012-09-25T22:50:26Z",
    "created_at": "2012-09-25T22:50:26Z"
  }
}
```

### List active Triggers
`GET /api/v2/triggers/active.json`

Lists all active triggers

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/triggers/active.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "triggers": [
     {
      "id": 25,
      "title": "Close and Save",
      "active": true
      "conditions": [ ... ],
      "actions": [ ... ],
      "updated_at": "2012-09-25T22:50:26Z",
      "created_at": "2012-09-25T22:50:26Z"
    },
    {
      "id": 28,
      "title": "Close and redirect to topics",
      "active": true
      "conditions": [ ... ],
      "actions": [ ... ],
      "updated_at": "2012-09-25T22:50:26Z",
      "created_at": "2012-09-25T22:50:26Z"
    }
  ],
  "count": 2,
  "previous_page": null,
  "next_page": null
}
```

### Create Trigger
`POST /api/v2/triggers.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/triggers.json \
  -H "Content-Type: application/json" -X POST -d \
  '{"trigger":{"title":"Roger Wilco", "all": [{ "field": "status", "operator": "is", "value": "open" }], "actions": [{ "field": "status", "value": "closed" }]}}'
```

#### Example Response

```http
Status: 201 Created
Location: /api/v2/trigger/{new-trigger-id}.json

{
  "trigger": {
    "id":   9873843,
    "title": "Roger Wilco",
    ...
  }
}
```

### Update Trigger
`PUT /api/v2/triggers/{id}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/triggers/{id}.json \
  -H "Content-Type: application/json" -X PUT -d '{"trigger":{"title":"Roger Wilco II"}}'
```

#### Example Response

```http
Status: 200 OK

{
  "trigger": {
    "id":   9873843,
    "title": "Roger Wilco II",
    ...
  }
}
```
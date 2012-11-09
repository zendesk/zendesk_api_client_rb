## Group Memberships

A membership links an agent to a group. Groups can have many agents, as agents can be in many groups. You can use the API to list what agents are in which groups, and reassign group members.

### JSON Format
Memberships are simple links between a user and a group

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned upon creation
| url             | string  | yes       | no        | The API url of this record
| user_id         | integer | no        | yes       | The id of an agent
| group_id        | integer | no        | yes       | The id of a group
| default         | boolean | no        | no        | If true, tickets assigned directly to the agent will assume this membership's group.
| created_at      | date    | yes       | no        | The time the membership was created
| updated_at      | date    | yes       | no        | The time of the last update of the membership

#### Example
```js
{
  "id":         4,
  "user_id":    29,
  "group_id":   12,
  "default":    true,
  "created_at": "2009-05-13T00:07:08Z",
  "updated_at": "2011-07-22T00:11:12Z"
}
```

### List Memberships
`GET /api/v2/group_memberships.json`

`GET /api/v2/users/{user_id}/group_memberships.json`

`GET /api/v2/groups/{group_id}/memberships.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/group_memberships.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "group_memberships": [
    {
      "id":         4,
      "user_id":    29,
      "group_id":   12,
      "default":    true,
      "created_at": "2009-05-13T00:07:08Z",
      "updated_at": "2011-07-22T00:11:12Z"
    },
    {
      "id":         49,
      "user_id":    155,
      "group_id":   3,
      "default":    false,
      "created_at": "2012-03-13T22:01:32Z",
      "updated_at": "2012-03-13T22:01:32Z"
    }
  ]
}
```

### List Assignable Memberships
`GET /api/v2/group_memberships/assignable.json`

`GET /api/v2/groups/{group_id}/memberships/assignable.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/group_memberships/assignable.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "group_memberships": [
    {
      "id":         4,
      "user_id":    29,
      "group_id":   12,
      "default":    true,
      "created_at": "2009-05-13T00:07:08Z",
      "updated_at": "2011-07-22T00:11:12Z"
    },
    {
      "id":         49,
      "user_id":    155,
      "group_id":   3,
      "default":    false,
      "created_at": "2012-03-13T22:01:32Z",
      "updated_at": "2012-03-13T22:01:32Z"
    }
  ]
}
```

### Show Membership
`GET /api/v2/group_memberships/{id}.json`

`GET /api/v2/users/{user_id}/group_memberships/{id}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/group_memberships/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "group_membership": {
     "id":         4,
     "user_id":    29,
     "group_id":   12,
     "default":    true,
     "created_at": "2009-05-13T00:07:08Z",
     "updated_at": "2011-07-22T00:11:12Z"
  }
}
```

### Create Membership
`POST /api/v2/group_memberships.json`

`POST /api/v2/users/{user_id}/group_memberships.json`

Creating a membership means assigning an agent to a given group

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/group_memberships.json \
  -X POST -d '{"group_membership": {"user_id": 72, "group_id": 88}}' \
  -H "Content-Type: application/json" -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/group_memberships/{id}.json

{
  "group_membership": {
     "id":         461,
     "user_id":    72,
     "group_id":   88,
     "default":    true,
     "created_at": "2012-04-03T12:34:01Z",
     "updated_at": "2012-04-03T12:34:01Z"
  }
}
```

### Delete Membership
`DELETE /api/v2/group_memberships/{id}.json`

`DELETE /api/v2/users/{user_id}/group_memberships/{id}.json`

Immediately removes a user from a group and schedules a job to unassign all working tickets
that are assigned to the given user and group combination

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/group_memberships/{id}.json \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```

### Set membership as default
`PUT /api/v2/users/{user_id}/group_memberships/{id}/make_default.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/group_memberships/{id}/make_default.json \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response

Same as List Memberships
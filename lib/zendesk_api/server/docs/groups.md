## Groups

When support requests arrive in Zendesk, they can be assigned to a Group.  Groups serve as the core element of ticket workflow; support agents are organized into Groups and tickets can be assigned to a Group only, or to an assigned agent within a Group.  A ticket can never be assigned to an agent without also being assigned to a Group.

### JSON Format
Groups are represented as simple flat JSON objects which have the following keys:

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned when creating groups
| url             | string  | yes       | no        | The API url of this group
| name            | string  | no        | yes       | The name of the group
| deleted         | boolean | yes       | no        | Deleted groups get marked as such
| created_at      | date    | yes       | no        | The time the group was created
| updated_at      | date    | yes       | no        | The time of the last update of the group

#### Example
```js
{
  "id":         3432,
  "url":        "https://company.zendesk.com/api/v2/groups/3432.json",
  "deleted",    false,
  "name":       "First Level Support",
  "created_at": "2009-07-20T22:55:29Z",
  "updated_at": "2011-05-05T10:38:52Z"
}
```

### List Groups
`GET /api/v2/groups.json`

#### Allowed For:

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/groups.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "groups": [
    {
      "name":       "DJs",
      "created_at": "2009-05-13T00:07:08Z",
      "updated_at": "2011-07-22T00:11:12Z",
      "id":         211
    },
    {
      "name":       "MCs",
      "created_at": "2009-08-26T00:07:08Z",
      "updated_at": "2010-05-13T00:07:08Z",
      "id":         122
    }
  ]
}
```

### Show assignable groups
`GET /api/v2/groups/assignable.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/groups/assignable.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "groups": [
    {
      "name":       "DJs",
      "created_at": "2009-05-13T00:07:08Z",
      "updated_at": "2011-07-22T00:11:12Z",
      "id":         211
    },
    {
      "name":       "MCs",
      "created_at": "2009-08-26T00:07:08Z",
      "updated_at": "2010-05-13T00:07:08Z",
      "id":         122
    }
  ]
}
```

### Show Group
`GET /api/v2/groups/{id}.json`

#### Allowed For

 * Admins
 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/groups/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "group": {
    "name":       "MCs",
    "created_at": "2009-08-26T00:07:08Z",
    "updated_at": "2010-05-13T00:07:08Z",
    "id":         122
  }
}
```

### Create Groups
`POST /api/v2/groups.json`

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/groups.json \
  -H "Content-Type: application/json" -d '{"group": {"name": "My Group"}}'
  -v -u {email_address}:{password} -X POST
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/groups/{id}.json

{
  "group": {
    "name":       "MCs",
    "created_at": "2009-08-26T00:07:08Z",
    "updated_at": "2010-05-13T00:07:08Z",
    "id":         122
  }
}
```

### Update Groups
`PUT /api/v2/groups/{id}.json`

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/groups/{id}.json \
  -H "Content-Type: application/json" -d '{"group": {"name": "Interesting Group"}}' \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response

```http
Status: 200 OK

{
  "group": {
    "name":       "Interesting Group",
    "created_at": "2011-04-20T17:49:00Z",
    "updated_at": "2011-07-20T17:49:00Z",
    "id":         123
  }
}
```

### Delete Group
`DELETE /api/v2/groups/{id}.json`

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/groups/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK
```
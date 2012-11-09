## Side-Loading
### Overview
Side loading is an API feature that allows you to retrieve related records as part of a single request. For example, consider getting a list of group memberships, your response looks like this:

```js
{
  "group_memberships": [
    {
      "id":       4,
      "user_id":  29,
      "group_id": 12,
      "created_at": "2009-05-13T00:07:08Z",
      "updated_at": "2011-07-22T00:11:12Z"
    },
    {
      "id":       49,
      "user_id":  155,
      "group_id": 3,
      "created_at": "2012-03-13T22:01:32Z",
      "updated_at": "2012-03-13T22:01:32Z"
    }
  ]
}
```

By allowing side loading of users and groups, this response turns into:

```js
{
  "group_memberships": [
    {
      "id":       4,
      "user_id":  29,
      "group_id": 12,
      "created_at": "2009-05-13T00:07:08Z",
      "updated_at": "2011-07-22T00:11:12Z"
    },
    {
      "id":       49,
      "user_id":  155,
      "group_id": 3,
      "created_at": "2012-03-13T22:01:32Z",
      "updated_at": "2012-03-13T22:01:32Z"
    }
  ],
  "users": [
    { "id": 29, ... },
    { "id": 155, ... }
  ],
  "groups": [
    { "id": 12, ... },
    { "id": 3, ... }
  ]
}
```

Meaning, we now return the full serialized representation of users and groups referred from the primary collection being retrieved. In order to side load resources, all you need to do is to add `include=users,groups` parameter to the HTTP request.

### Special Sideloads

#### Abilities

A resource may have an additional `abilities` sideload which represents the abilities that the current user has on a given resource. For example:

`GET /api/v2/users/me.json?include=abilities`

```js
{
  "abilities": [
    {
      "can_edit": true,
      "can_edit_password": true,
      "can_manage_identities_of": true,
      "can_verify_identities": false,
      "url": "http://dev.localhost:3001/api/v2/users/11.json",
      "user_id": 11
    }
  ],
  "user": {
    "active": true,
    "alias": null,
    "created_at": "2012-05-08T01:04:47Z",
    "custom_role_id": null,
    "details": null,
    "email": "agent@zendesk.com",
    "external_id": null,
    "id": 11,
    "last_login_at": "2012-05-21T21:19:19Z",
    "locale_id": null,
    "moderator": true,
    "name": "Agent Extraordinaire",
    "notes": null,
    "only_private_comments": false,
    "organization_id": 11,
    "phone": null,
    "photo": null,
    "role": "admin",
    "shared": false,
    "signature": null,
    "suspended": false,
    "tags": [],
    "ticket_restriction": null,
    "time_zone": "Pacific Time (US & Canada)",
    "updated_at": "2012-05-08T01:04:47Z",
    "url": "http://dev.localhost:3001/api/v2/users/11.json",
    "verified": true
  }
}
```

### Supported End Points

Currently the below end points support side loading. You can side load a single type of resource, or given in the examples.

  * `/api/v2/organizations.json?include=users,groups`
  * `/api/v2/tickets/123/audits.json?include=users,organizations,groups,tickets`
  * `/api/v2/tickets/123.json?include=users,organizations,groups`
  * `/api/v2/users/123.json?include=organizations,abilities,custom_roles`
  * `/api/v2/memberships.json?include=users,groups`
  * `/api/v2/topics.json?include=users,forums`
  * `/api/v2/forums/123/topics.json?include=users`
  * `/api/v2/users/123/topics.json?include=users`
  * `/api/v2/topic_comments.json?include=users`
  * `/api/v2/topics/123/comments.json?include=users`
  * `/api/v2/users/123/topic_comments.json?include=users`
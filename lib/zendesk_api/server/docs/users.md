## Users

Zendesk has three main types of users: End-users (your customers), Agents and Administrators.

#### End-users

End-users request support via Tickets.  End-users have access to the Zendesk end-user portal where they can view forum content, access their ticket history, and submit new Tickets.

#### Agents

Agents work in Zendesk to solve Tickets. Agents can be divided into multiple Groups and can also belong to multiple Groups. Agents do not have access to administrative configuration in Zendesk such as business rules or automations, but can configure their own Macros and Views.

#### Administrators

Administrators have all the abilities of Agents, plus administrative abilities.  Accounts on the Enterprise plan can configure custom roles to give Agents varying degrees of administrative access.

### Show Requested Tickets, CCed Tickets and Topics for a User

See our Tickets API to retrieve [tickets requested by a User](tickets.html#listing-tickets), [tickets on which a user is CCed](tickets.html#listing-tickets).

See our Topics API to retrieve [topics created by a User](topics.html#list-topics) and [topic comments from a User](topic_comments.html#list-topic-comments).

### JSON Format
Users are represented as JSON objects which have the following keys:

| Name                  | Type                         | Read-only | Mandatory | Comment
| --------------------- | ---------------------------- | --------- | --------- | -------
| id                    | integer                      | yes       | no        | Automatically assigned when creating users
| url                   | string                       | yes       | no        | The API url of this user
| name                  | string                       | no        | yes       | The name of the user
| external_id           | string                       | no        | no        | A unique id you can set on a user
| alias                 | string                       | no        | no        | Agents can have an alias that is displayed to end-users
| created_at            | date                         | yes       | no        | The time the user was created
| updated_at            | date                         | yes       | no        | The time of the last update of the user
| active                | boolean                      | yes       | no        | Users that have been deleted will have the value `false` here
| verified              | boolean                      | no        | no        | Zendesk has verified that this user is who he says he is
| shared                | boolean                      | yes       | no        | If this user is shared from a different Zendesk, ticket sharing accounts only
| locale_id             | integer                      | no        | no        | The language identifier for this user
| time_zone             | string                       | no        | no        | The time-zone of this user
| last_login_at         | date                         | yes       | no        | A time-stamp of the last time this user logged in to Zendesk
| email                 | string                       | no        | yes       | The primary email address of this user
| phone                 | string                       | no        | no        | The primary phone number of this user
| identities            | Array                        | no        | no        | Array of user identities (e.g. email and Twitter) associated with this user. See [User Identities](user_identities.html)
| signature             | string                       | no        | no        | The signature of this user. Only agents and admins can have signatures
| details               | string                       | no        | no        | In this field you can store any details obout the user. e.g. the address
| notes                 | string                       | no        | no        | In this field you can store any notes you have about the user
| organization_id       | integer                      | no        | no        | The id of the organization this user is associated with
| role                  | string                       | no        | yes       | The role of the user. Possible values: `"end-user"`, `"agent"`, `"admin"`
| custom_role_id        | integer                      | no        | no        | A custom role on the user if the user is an agent on the entreprise plan
| moderator             | boolean                      | no        | no        | Designates whether this user has forum moderation capabilities
| ticket_restriction    | string                       | no        | no        | Specified which tickets this user has access to. Possible values are: `"organization"`, `"groups"`, `"assigned"`, `"requested"`, `null`
| only_private_comments | boolean                      | no        | no        | `true` if this user only can create private comments
| tags                  | array                        | no        | no        | The tags of the user. Only present if your account has user tagging enabled
| suspended             | boolean                      | no        | no        | Tickets from suspended users are also suspended, and these users cannot log in to the end-user portal
| photo                 | [Attachment](attachments.md) | no        | no        | The user's profile picture represented as an [Attachment](attachments.md) object

#### Example
```js
{
  "id":                    35436,
  "url":                   "https://company.zendesk.com/api/v2/users/35436.json",
  "name":                  "Johnny Agent",
  "external_id":           "sai989sur98w9",
  "alias":                 "Mr. Johnny",
  "created_at":            "2009-07-20T22:55:29Z",
  "updated_at":            "2011-05-05T10:38:52Z",
  "active":                true,
  "verified":              true,
  "shared":                false,
  "locale_id":             1,
  "time_zone":             "Copenhagen",
  "last_login_at":         "2011-05-05T10:38:52Z",
  "email":                 "johnny@example.com",
  "phone":                 "555-123-4567",
  "signature":             "Have a nice day, Johnny",
  "details":               "",
  "notes":                 "Johnny is a nice guy!",
  "organization_id":       57542,
  "role":                  "agent",
  "custom_role_id":        9373643,
  "moderator":             true,
  "ticket_restriction":    "assigned",
  "only_private_comments": false,
  "tags":                  ["enterprise", "other_tag"],
  "suspended":             true,
  "photo": {
    "id":           928374,
    "name":         "my_funny_profile_pic.png",
    "content_url":  "https://company.zendesk.com/photos/my_funny_profile_pic.png",
    "content_type": "image/png",
    "size":         166144,
    "thumbnails": [
      {
        "id":           928375,
        "name":         "my_funny_profile_pic_thumb.png",
        "content_url":  "https://company.zendesk.com/photos/my_funny_profile_pic_thumb.png",
        "content_type": "image/png",
        "size":         58298,
      }
    ]
  }
}
```

### List Users

`GET /api/v2/users.json`

`GET /api/v2/groups/{id}/users.json`

`GET /api/v2/organizations/{id}/users.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200

{
  "users": [
    {
      "id": 223443,
      "name": "Johnny Agent",
      ...
    },
    {
      "id": 8678530,
      "name": "James A. Rosen",
      ...
    }
  ]
}
```

### Show User

`GET /api/v2/users/{id}.json`

#### Allowed For:

 * Agents

#### Using curl:

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200

{
  "user": {
    "id":   35436,
    "name": "Johnny Agent",
    ...
  }
}
```

### Create User
`POST /api/v2/users.json`

#### Allowed For

 * Agents, restrictions apply on certain actions

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/users.json \
  -H "Content-Type: application/json" -X POST -d '{"user": {"name": "Roger Wilco", "email": "roge@example.org"}}'
```

If you need to create users without sending out a verification email, pass a `"verified": true` parameter.

#### Example Response

```http
Status: 201 Created
Location: /api/v2/users/{new-user-id}.json

{
  "user": {
    "id":   9873843,
    "name": "Roger Wilco",
    ...
  }
}
```

### Create User with Multiple Identities

If you have a user with multiple identities, such as email addresses and Twitter accounts, you can also include
these values at creation time. This is especially useful when importing users from another system.

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/users.json \
  -H "Content-Type: application/json" -X POST -d '{"user": {"name": "Roger Wilco", "identities": [{ "type": "email", "value": "test@user.com"}, {"type": "twitter", "value": "tester84" }]}}'
```

### Create Many Users
`POST /api/v2/users/create_many.json`

#### Allowed For

 * Agents, restrictions apply on certain actions

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/users/create_many.json \
  -H "Content-Type: application/json" -X POST -d '{"users": [{"name": "Roger Wilco", "email": "roge@example.org", "role": "agent"}, {"name": "Woger Rilco", "email": "woge@example.org", "role": "admin"}]}'
```

#### Example Response

See [Job Status](job_statuses.md#show-job-status)

### Update User
`PUT /api/v2/users/{id}.json`

#### Allowed For

 * Agents, restrictions apply on certain actions

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/users/{id}.json \
  -H "Content-Type: application/json" -X PUT -d '{"user": {"name": "Roger Wilco II"}}'
```

#### Example Response

```http
Status: 200 OK

{
  "user": {
    "id":   9873843,
    "name": "Roger Wilco II",
    ...
  }
}
```

### Suspending a User

You can suspend a User by setting its `suspended` attribute to `true`.

When a User is suspended, the User is not allowed to login to the end-user portal and
all further tickes are suspended.

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/users/{id}.json \
  -H "Content-Type: application/json" -X PUT -d '{"user": {"suspended":true}}'
```

#### Example Response

```js
{
  "user": {
    "id":        9873843,
    "name":      "Roger Wilco II",
    "suspended": true,
    ...
  }
}
```

### Delete User
`DELETE /api/v2/users/{id}.json`

#### Allowed For

 * Agents, restrictions apply on certain actions

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/users/{id}.json \
  -X DELETE
```

#### Example Response

```http
Status: 200 OK

{
  "user": {
    "id":     9873843,
    "name":   "Roger Wilco II",
    ...
    "active": false,
    ...
  }
}
```

### Search Users
`GET /api/v2/users/search.json?query={query}`

`GET /api/v2/users/search.json?external_id={external_id}`

You can find a specific user given their `external_id` attribute or email address. Or perform
a search across usernames and email addresses.

#### Allowed For:

 * Agents

#### Example Response

```http
Status: 200

[
  { .. user record as in the #show method .. },
  { .. user record as in the #show method .. }
]
```

### Autocomplete Users
`POST /api/v2/users/autocomplete.json?name={name}`


#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/autocomplete.json \
  -X POST -d '{"name": "att"}' -H "Accept: application/json" \
  -u {email_address}:{password}
```

#### Example Response

```http
Status: 200

[
  { .. user record as in the #show method .. },
  { .. user record as in the #show method .. }
]
```

### Update a User's Profile Image

A user's profile image can be updated by uploading a local file or by
referring to an image hosted on a different website. The latter may take
a few minutes to process.

#### Using curl

Uploading a local file.

```bash
curl -v -u {email_address}:{password} -X PUT \
  -F "user[photo][uploaded_data]=@/path/to/profile/image.jpg" \
  http://{subdomain}.zendesk.com/api/v2/users/{id}.json
```

Setting a remote image URL.

```bash
curl -v -u {email_address}:{password} -X PUT -H "Content-Type: application/json" \
  -d '{"user": {"remote_photo_url": "http://link.to/profile/image.png"}}' \
  http://{subdomain}.zendesk.com/api/v2/users/{id}.json
```

### Show the Currently Authenticated User
`GET /api/v2/users/me.json`

#### Allowed For:

 * Anyone

#### Example Response

```http
Status: 200

{
  "user": {
    "id":   35436,
    "name": "Roger Wilco",
    ...
  }
}
```

### Set a User's Password

`POST /api/v2/users/{user_id}/password.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/password.json \
  -d '{"password": "newpassword"}' \
  -v -u {email_address}:{password} -X POST -H "Content-Type: application/json"
```

#### Example Response

```http
Status: 200
```

### Change a User's Password

`PUT /api/v2/users/{user_id}/password.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/password.json \
  -d '{"previous_password": "oldpassword", "password": "newpassword"}' \
  -v -u {email_address}:{password} -X PUT -H "Content-Type: application/json"
```

#### Example Response

```http
Status: 200
```
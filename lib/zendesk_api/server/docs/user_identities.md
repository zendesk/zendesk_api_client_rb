## User Identities

A user identity is something that can be used to identify an individual. Most likely, it's an email address, a twitter handle or a phone number. Zendesk supports a series of different such identities.

### JSON Format
User identities have the following keys:

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned upon creation
| url             | string  | yes       | no        | The API url of this identity
| user_id         | integer | yes       | yes       | The id of the user
| type            | string  | yes       | yes       | One of "email", "twitter", "facebook", "google", or "phone_number"
| value           | string  | yes       | yes       | The identifier for this identity, e.g. an email address
| verified        | boolean | no        | no        | Is true of the identity has gone through verification
| primary         | boolean | no        | no        | Is true of the primary identity of the user
| created_at      | date    | yes       | no        | The time the identity got created
| updated_at      | date    | yes       | no        | The time the identity got updated

#### Example
```js
{
  "id":              35436,
  "url":              "https://company.zendesk.com/api/v2/users/135/identities/35436.json",
  "user_id":         135,
  "type":            "email",
  "value":           "someone@example.com",
  "verified":        true,
  "primary":         true,
  "updated_at":      "2011-07-20T22:55:29Z",
  "created_at":      "2011-07-20T22:55:29Z"
}
```

### List User Identities
`GET /api/v2/users/{user_id}/identities.json`

 Returns all user identities for a given user id

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/identities.json \
  -v -u {email_address}:{password}
```

#### Example Response:

```http
Status: 200 OK

{
  "identities": [
    {
      "id":              35436,
      "user_id":         135,
      "type":            "email",
      "value":           "someone@example.com",
      "verified":        true,
      "primary":         true,
      "updated_at":      "2011-07-20T22:55:29Z",
      "created_at":      "2011-07-20T22:55:29Z"
    },
    {
      "id":              77136,
      "user_id":         135,
      "type":            "twitter",
      "value":           "didgeridooboy",
      "verified":        true,
      "primary":         false,
      "updated_at":      "2012-02-12T14:25:21Z",
      "created_at":      "2012-02-12T14:25:21Z"
    }
  ]
}
```

### Show a User Identity
`GET /api/v2/users/{user_id}/identities/{id}.json`

 Shows the identity with the given id

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/identities/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response:

```http
Status: 200 OK

{
  "id":              77938,
  "user_id":         13531,
  "type":            "twitter",
  "value":           "cabanaboy",
  "verified":        false,
  "primary":         false,
  "updated_at":      "2012-02-12T14:25:21Z",
  "created_at":      "2012-02-12T14:25:21Z"
}
```

### Add User Identity
`POST /api/v2/users/{user_id}/identities.json`

 Add new identities for a given user id. Identities that can be added are:

   * email    - e.g., `{ "type" : "email",    "value" : "someone@example.com" }`
   * twitter  - e.g., `{ "type" : "twitter",  "value" : "screen_name" }`
   * facebook - e.g., `{ "type" : "facebook", "value" : "855769377321" }`
   * google   - e.g., `{ "type" : "google",   "value" : "example@gmail.com" }`

If you need to create an identity without sending out a verification email, pass a `"verified": true` parameter.

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/identities.json \
  -H "Content-Type: application/json" -X POST \
  -d '{"identity": {"type": "email", "value": "foo@bar.com"}}' -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/users/135/identities/78138.json

{
  "id":              78138,
  "user_id":         135,
  "type":            "twitter",
  "value":           "cabanaboy",
  "verified":        false,
  "primary":         false,
  "updated_at":      "2012-02-12T14:25:21Z",
  "created_at":      "2012-02-12T14:25:21Z"
}
```

### Update a given User Identity
`PUT /api/v2/users/{user_id}/identities/{id}.json?identity[verified]=true`

 This API method only allows you to set an identity as verified. You cannot otherwise
 change value of an identity but must create a new identity and delete the one you're
 replacing.

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/identities/{id}.json \
  -H "Content-Type: application/json" -X PUT \
  -d '{"identity": {"verified": true}}' -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "id":              78138,
  "user_id":         135,
  "type":            "twitter",
  "value":           "cabanaboy",
  "verified":        true,
  "primary":         false,
  "updated_at":      "2012-02-12T14:25:21Z",
  "created_at":      "2012-02-12T14:25:21Z"
}
```

### Make a User Identity the Primary
`PUT /api/v2/users/{user_id}/identities/{id}/make_primary`

 This API method only allows you to set an identity to primary. If you wish to change an identity, you
 create a new one with the correct value and delete the old one. This is a collection level operation
 and the correct behavior for an API client is to subsequently reload the entire collection.

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/identities/{id}/make_primary.json \
  -X PUT -v -u {email_address}:{password}
```

#### Example Response

Same as List User Identities


### Verify a given User Identity
`PUT /users/{user_id}/identities/{id}/verify`

 This API method only allows you to set an identity as verified.

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/identities/{id}/verify.json \
  -X PUT -v -u {email_address}:{password}
```

#### Example Response

Same as Show a User Identity


### Request User Verification
`PUT /users/{user_id}/identities/{id}/request_verification

 This sends a verification email to the user, asking him to click a link in order to verify ownership of the email address

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/identities/{id}/request_verification.json \
  -X PUT -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK
```

### Delete User Identity
`DELETE /users/{user_id}/identities/{id}.json`

 Delete identity for a given user

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/users/{user_id}/identities/{id}.json \
  -X DELETE -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK
```
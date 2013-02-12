## Topic Votes

### JSON Format
Topic votes have the following keys:

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned when creating a vote
| user_id         | integer | yes       | yes       | The id of the user who votes on the topic
| topic_id        | integer | yes       | yes       | The id of the topic voted on
| created_at      | date    | yes       | no        | The time the vote was cast

#### Example
```js
{
  "id":              35436,
  "user_id":         135,
  "topic_id":        559,
  "created_at":      "2011-07-20T22:55:29Z"
}
```

### List Topic Votes

Allows agents to see votes cast on a topic or by a specific user.

`GET /api/v2/topics/{id}/votes.json`

`GET /api/v2/users/{id}/topic_votes.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{id}/votes.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "topic_votes": [
    {
      "id":              35436,
      "user_id":         135,
      "topic_id":        559,
      "created_at":      "2011-07-20T22:55:29Z"
    },
    {
      "id":              39316,
      "user_id":         85,
      "topic_id":        559,
      "created_at":      "2012-01-10T12:53:42Z"
    }
  ]
}
```

Agents can pass a `user_id={user_id}` to all actions below to control voting for specific users.

### Check for Vote
`GET /api/v2/topics/{id}/vote.json`

#### Allowed For

 * Anyone who is logged in

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{id}/vote.json \
  -v -u {email_address}:{password}
```

#### Example Response

If the current user has not cast a vote in the topic

```http
Status: 404 Not Found
```

If the current user has cast a vote in the topic

```http
Status: 200 OK

{
  "topic_vote": {
    "id":              35436,
    "user_id":         135,
    "topic_id":        559,
    "created_at":      "2011-07-20T22:55:29Z"
  }
}
```

### Create Vote
`POST /api/v2/topics/{id}/vote.json`

#### Allowed For

 * Any logged in user who has not already cast a vote in the given topic

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{id}/vote.json \
  -H "Content-Type: application/json" -X POST -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/topics/{id}.json

{
  "topic_vote": {
    "id":              35436,
    "user_id":         135,
    "topic_id":        559,
    "created_at":      "2012-03-20T22:55:29Z"
  }
}
```

### Delete Vote
`DELETE /api/v2/topics/{id}/vote.json`

#### Allowed For

 * The user who cast the vote
 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{id}/vote.json \
  -H "Content-Type: application/json" -X DELETE -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK
```
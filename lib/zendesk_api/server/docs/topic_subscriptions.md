## Topic Subscriptions

### JSON Format
Topic subscriptions are links between users and topics they subscribe to

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned upon creation
| topic_id        | integer | no        | yes       | The topic being subscribed to
| user_id         | integer | no        | yes       | The user subscribed to the forum
| created_at      | date    | yes       | no        | The time the subscription was created

#### Example
```js
{
  "id":              35436,
  "url":             "https://company.zendesk.com/api/v2/topic_subscriptions/35436.json",
  "topic_id":        32,
  "user_id":         482,
  "created_at":      "2009-07-20T22:55:29Z"
}
```

### List Topic Subscriptions
`GET /api/v2/topics/{topic_id}/subscriptions.json`

`GET /api/v2/topic_subscriptions.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topic_subscriptions.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "topic_subscriptions": [
    {
      "id":              35436,
      "topic_id":        32,
      "user_id":         482,
      "created_at":      "2009-07-20T22:55:29Z"
    },
    {
      "id":              43681,
      "topic_id":        334,
      "user_id":         9471,
      "created_at":      "2011-08-22T21:12:09Z"
    }
  ]
}
```

### Show Topic Subscription
`GET /api/v2/topic_subscriptions/{id}.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topic_subscriptions/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "topic_subscription": {
    "id":              35436,
    "topic_id":        32,
    "user_id":         482,
    "created_at":      "2009-07-20T22:55:29Z"
  }
}
```

### Create Topic Subscription
`POST /api/v2/topic_subscriptions.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topic_subscriptions.json \
  -d '{"topic_subscription": {"user_id": 772, "topic_id": 881}}' \
  -v -u {email_address}:{password} -H "Content-Type: application/json" -X POST
```

#### Example Response

```http
Status: 200 OK

{
  "topic_subscription": {
    "id":              55436,
    "topic_id":        881,
    "user_id":         772,
    "created_at":      "2012-04-20T22:55:29Z"
  }
}
```

### Delete Topic Subscription
`DELETE /api/v2/topic_subscriptions/{id}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topic_subscriptions/{id}.json \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```
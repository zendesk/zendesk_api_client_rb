## Topic Comments

### JSON Format
TopicComments are represented as simple flat JSON objects which have the following keys:

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned upon creation
| url             | string  | yes       | no        | The API url of this topic comment
| topic_id        | integer | no        | yes       | The id of the topic this comment was made on
| user_id         | integer | no        | yes       | The id of the user making the topic comment
| body            | string  | no        | yes       | The comment body
| informative     | boolean | no        | no        | If the comment has been flagged as informative
| attachments     | array   | yes       | no        | Attachments to this comment as [Attachment](attachments.md) objects
| created_at      | date    | yes       | no        | The time the topic_comment was created
| updated_at      | date    | yes       | no        | The time of the last update of the topic_comment

#### Example
```js
{
  "id":              35436,
  "url":             "https://company.zendesk.com/api/v2/topics/118/comments/35436.json",
  "topic_id":        118,
  "user_id":         9442,
  "body":            "I think this is a great topic",
  "informative":     false,
  "attachments": [
    {
      "id":           498483,
      "name":         "crash.log",
      "content_url":  "https://company.zendesk.com/attachments/crash.log",
      "content_type": "text/plain",
      "size":         2532,
      "thumbnails":   []
    }
  ]
  "created_at":      "2009-07-20T22:55:29Z",
  "updated_at":      "2011-05-05T10:38:52Z"
}
```

### List Topic Comments
`GET /api/v2/topics/{id}/comments.json`

`GET /api/v2/users/{id}/topic_comments.json`

#### Allowed For:

* Admins on non-enterprise accounts
* Admins and agents with full forum access on enterprise accounts
* Users in general as permitted by the forum the topic is in

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{id}/comments.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "topic_comments": [
    {
      "id":              35436,
      "topic_id":        118,
      "user_id":         9442,
      "body":            "I think this is a great topic",
      "informative":     false,
      "attachments":     []
      "created_at":      "2012-02-20T22:55:29Z",
      "updated_at":      "2012-03-05T10:38:52Z"
    },
    {
      "id":              54438,
      "topic_id":        118,
      "user_id":         1423,
      "body":            "This topic is not quite for me",
      "informative":     true,
      "attachments":     []
      "created_at":      "2012-03-20T22:55:29Z",
      "updated_at":      "2012-03-20T22:55:29Z"
    }
  ]
}
```

### Show Topic Comment
`GET /api/v2/topics/{topic_id}/comments/{id}.json`

`GET /api/v2/users/{user_id}/topic_comments/{id}.json`

#### Allowed For

* Admins on non-enterprise accounts
* Admins and agents with full forum access on enterprise accounts
* Users in general as permitted by the forum the topic is in

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{topic_id}/comments/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "topic_comment": {
    "id":              35436,
    "topic_id":        118,
    "user_id":         9442,
    "body":            "I think this is a great topic",
    "informative":     false,
    "attachments":     []
    "created_at":      "2012-02-20T22:55:29Z",
    "updated_at":      "2012-03-05T10:38:52Z"
  }
}
```

### Create Topic Comment
`POST /api/v2/topics/{id}/comments.json`

#### Allowed For

* Users in general as permitted by the forum the topic is in

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{id}/comments.json \
  -H "Content-Type: application/json" -d '{"topic_comment": {"body": "A man walks into a bar"}}' \
  -v -u {email_address}:{password} -X POST
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/topics/{topic_id}/comments/{id}.json

{
  "topic_comment": {
    "id":              35436,
    "topic_id":        118,
    "user_id":         9442,
    "body":            "A man walks into a bar",
    "informative":     false,
    "attachments":     []
    "created_at":      "2012-03-05T10:38:52Z",
    "updated_at":      "2012-03-05T10:38:52Z"
  }
}
```

### Update Topic Comment
`PUT /api/v2/topics/{topic_id}/comments/{id}.json`

#### Allowed For

These are subject to the current permission settings on the enclosing account

* Admins on non-enterprise accounts
* Admins and agents with full forum access on enterprise accounts
* The user who created the original comment

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{topic_id}/comments/{id}.json \
  -H "Content-Type: application/json" -d '{"topic_comment": {"body": "A woman walks into a bar"}}' \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response

```http
Status: 200 OK

{
  "topic_comment": {
    "id":              35436,
    "topic_id":        118,
    "user_id":         9442,
    "body":            "A woman walks into a bar",
    "informative":     false,
    "attachments":     []
    "created_at":      "2012-03-05T10:38:52Z",
    "updated_at":      "2012-03-05T12:38:52Z"
  }
}
```

### Delete Topic Comment
`DELETE /api/v2/topics/{topic_id}/comments/{id}.json`

#### Allowed For

* Admins on non-enterprise accounts
* Admins and agents with full forum access on enterprise accounts
* The user who created the original comment

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{topic_id}/comments/{id}.json \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```
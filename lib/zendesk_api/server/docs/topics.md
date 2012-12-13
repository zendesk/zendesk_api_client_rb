## Topics

### JSON Format
Topics are represented in JSON with the below attributes

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned upon creation
| url             | string  | yes       | no        | The API url of this topic
| title           | string  | no        | yes       | The title of the topic
| body            | string  | no        | yes       | The unescaped body of the topic
| topic_type      | string  | yes       | no        | The type of topic. Either "articles", "ideas" or "questions"
| submitter_id    | integer | no        | no        | The id of the user who submitted the topic
| updater_id      | integer | no        | no        | The id of the person to last update the topic
| forum_id        | integer | no        | no        | Forum that the topic is associated to
| locked          | boolean | no        | no        | Whether comments are allowed
| pinned          | boolean | no        | no        | If the topic is marked as pinned and hence eligible to show up on the front page
| highlighted     | boolean | no        | no        | Set to true to highlight a topic within its forum
| answered        | boolean | yes       | no        | Set to true if the topic is a question and it has been marked as answered.
| comments_count  | integer | yes       | no        | THe number of comments on this topic
| position        | integer | no        | no        | The position of this topic relative to other topics in the same forum
| tags            | array   | no        | no        | The tags set on the topic
| created_at      | date    | yes       | no        | The time the topic was created
| updated_at      | date    | yes       | no        | The time of the last update of the topic

#### Example
```js
{
  "id":              35436,
  "url":             "https://company.zendesk.com/api/v2/topics/35436.json",
  "title":           "How to Disassemble the ED209",
  "body":            "Carefully with very large pliers",
  "topic_type":      "articles",
  "submitter_id":    116,
  "updater_id":      116,
  "forum_id":        1239,
  "locked":          true,
  "pinned":          false,
  "locked":          true,
  "position":        1,
  "tags":            ["danger"]
  "created_at":      "2009-07-20T22:55:29Z",
  "updated_at":      "2011-05-05T10:38:52Z"
}
```

### List Topics
`GET /api/v2/topics.json`

`GET /api/v2/forums/{id}/topics.json`

`GET /api/v2/users/{id}/topics.json`

#### Allowed For:

 * Admins on non-enterprise accounts
 * Admins and agents with full forum access on enterprise accounts

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "topics": [
    {
      "id":              35436,
      "name":            "FAQs",
      "description:":    "This topic contains all product FAQs",
      "topic_type":      "questions",
      "category_id":     null,
      "organization_id": null,
      "locale_id":       null,
      "locked":          true,
      "position":        4,
      "access":          "everybody",
      "attachments": [
        {
          "id":          498483,
          "name":        "crash.log",
          "content_url": "https://company.zendesk.com/attachments/crash.log",
          "content_type": "text/plain",
          "size":        2532,
          "thumbnails":  []
        }
      ],
      "created_at":      "2010-07-20T22:55:29Z",
      "updated_at":      "2012-03-05T10:38:52Z"
    },
    {
      "id":              12,
      ...
      "created_at":      "2011-07-20T04:31:29Z",
      "updated_at":      "2012-02-02T10:32:59Z"
    }
  ]
}
```

### Show Topic
`GET /api/v2/topics/{id}.json`

#### Allowed For:

 * Users who are permitted to see the enclosing forum

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "topic": {
    "id":              35436,
    "title":           "How to Disassemble the ED209",
    "body":            "Carefully with very large pliers",
    "topic_type":      "articles",
    "submitter_id":    116,
    "updater_id":      116,
    "forum_id":        1239,
    "locked":          true,
    "pinned":          false,
    "locked":          true,
    "position":        1,
    "tags":            ["danger"],
    "attachments": [
      {
        "id":           498483,
        "name":         "crash.log",
        "content_url":  "https://company.zendesk.com/attachments/crash.log",
        "content_type": "text/plain",
        "size":         2532,
        "thumbnails":   []
      }
    ],
    "created_at":      "2011-05-05T10:38:52Z",
    "updated_at":      "2011-05-05T10:38:52Z"
  }
}
```

### Create Topic
`POST /api/v2/topics.json`

#### Allowed For

 * Admins, agents and users as permitted by the parent forum access settings

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics.json \
  -H "Content-Type: application/json" -v -u {email_address}:{password} -X POST \
  -d '{"topic": {"forum_id": 12, "title": "My Topic", "body": "This is a test topic."}}'
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/topics/{id}.json

{
  "topic": {
    "id":              35436,
    "title":           "My Topic",
    "body":            "Carefully with very large pliers",
    "topic_type":      "articles",
    "submitter_id":    116,
    "updater_id":      116,
    "forum_id":        1239,
    "locked":          true,
    "pinned":          false,
    "locked":          true,
    "position":        1,
    "tags":            ["danger"],
    "attachments": [
      {
        "id":           498483,
        "name":         "crash.log",
        "content_url":  "https://company.zendesk.com/attachments/crash.log",
        "content_type": "text/plain",
        "size":         2532,
        "thumbnails":   []
      }
    ],
    "created_at":      "2011-05-05T10:38:52Z",
    "updated_at":      "2011-05-05T10:38:52Z"
  }
}
```

### Show Multiple Topics
`POST /api/v2/topics/show_many.json?ids={ids}`

Accepts a comma separated list of topic ids to return.

#### Allowed For:

 * Admins
 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/show_many.json?ids={id,id,id} \
  -v -u {email_address}:{password} -X POST
```

#### Example Response

```http
Status: 200 OK

{
  "topics": [
    {
      "id":              35436,
      "name":            "FAQs",
      "description:":    "This topic contains all product FAQs",
      "topic_type":      "questions",
      "category_id":     null,
      "organization_id": null,
      "locale_id":       null,
      "locked":          true,
      "position":        4,
      "access":          "everybody",
      "attachments": [
        {
          "id":          498483,
          "name":        "crash.log",
          "content_url": "https://company.zendesk.com/attachments/crash.log",
          "content_type": "text/plain",
          "size":        2532,
          "thumbnails":  []
        }
      ],
      "created_at":      "2010-07-20T22:55:29Z",
      "updated_at":      "2012-03-05T10:38:52Z"
    },
    {
      "id":              12,
      ...
      "created_at":      "2011-07-20T04:31:29Z",
      "updated_at":      "2012-02-02T10:32:59Z"
    }
  ]
}
```

### Update Topic
`PUT /api/v2/topics/{id}.json`

#### Allowed For

 * Admins and agents as permitted by the parent forum access settings
 * The user who created the topic, restricted by the current parent forum access settings

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topics/{id}.json \
  -H "Content-Type: application/json" -d '{"topic": { "title": "How to Disassemble a Robot" }}' \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response

```http
Status: 200 OK

{
  "topic": {
    "id":              35436,
    "title":           "How to Disassemble a Robot",
    "body":            "Carefully with very large pliers",
    "topic_type":      "articles",
    "submitter_id":    116,
    "updater_id":      116,
    "forum_id":        1239,
    "locked":          true,
    "pinned":          false,
    "locked":          true,
    "position":        1,
    "tags":            ["danger"],
    "attachments": [
      {
        "id":           498483,
        "name":         "crash.log",
        "content_url":  "https://company.zendesk.com/attachments/crash.log",
        "content_type": "text/plain",
        "size":         2532,
        "thumbnails":   []
      }
    ],
    "created_at":      "2011-05-05T10:38:52Z",
    "updated_at":      "2012-03-11T14:09:18Z"
  }
}
```

### Delete Topic
`DELETE /api/v2/topics/{id}.json`

#### Allowed For

 * Admins and agents as permitted by the parent forum access settings
 * The user who created the topic, restricted by the current parent forum access settings

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/topic/{id}.json \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```
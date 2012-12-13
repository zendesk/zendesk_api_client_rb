## Forums

### JSON Format
Forums are represented with the following attributes:

| Name               | Type    | Read-only | Mandatory | Comment
| ------------------ | ------- | --------- | --------- | -------
| id                 | integer | yes       | no        | Automatically assigned upon creation
| url                | string  | yes       | no        | The API url of this forum
| name               | string  | no        | yes       | The name of the forum
| description        | string  | no        | no        | A description of the forum
| category_id        | integer | no        | no        | Category this forum is in
| organization_id    | integer | no        | no        | Organization this forum is restricted to
| locale_id          | integer | no        | no        | User locale id this forum is restricted to
| locked             | boolean | no        | no        | Whether this forum is locked such that new entries and comments cannot be made
| unanswered_topics  | integer | yes       | no        | Contains the number of unanswered questions if this forum's topics are questions.
| position           | integer | no        | no        | The position of this forum relative to other forums in the same category
| forum_type         | string  | no        | no        | The type of the topics in this forum, valid values: "articles", "ideas" or "questions"
| access             | string  | no        | no        | Who has access to this forum, valid values: "everybody", "logged-in users" or "agents only"
| created_at         | date    | yes       | no        | The time the forum was created
| updated_at         | date    | yes       | no        | The time of the last update of the forum

#### Example
```js
{
  "id":              35436,
  "url":             "https://company.zendesk.com/api/v2/forums/35436.json",
  "name":            "FAQs",
  "description:":    "This forum contains all product FAQs",
  "category_id":     null,
  "organization_id": null,
  "locale_id":       null,
  "locked":          true,
  "position":        4,
  "forum_type":      "articles",
  "access":          "everybody",
  "created_at":      "2010-07-20T22:55:29Z",
  "updated_at":      "2012-03-05T10:38:52Z"
}
```

### List Forums
`GET /api/v2/forums.json`

`GET /api/v2/categories/{id}/forums.json`

#### Allowed For:

 * Anyone on accounts that have at least one publicly accessible forum
 * End users and agents on accounts that have at least one logged-in user accessible forum
 * Admins

Only lists the forums available to the inquiring user as per the individual forum settings.

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/forums.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "forums": [
    {
      "id":              35436,
      "name":            "FAQs",
      "description:":    "This forum contains all product FAQs",
      "category_id":     null,
      "organization_id": null,
      "locale_id":       null,
      "locked":          true,
      "position":        4,
      "forum_type":      "articles",
      "access":          "everybody",
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

### Show Forum
`GET /api/v2/forums/{id}.json`

#### Allowed For:

 * Anyone with permission to access this specific forum

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/forums/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "forum": {
    "id":              35436,
    "name":            "FAQs",
    "description:":    "This forum contains all product FAQs",
    "category_id":     null,
    "organization_id": null,
    "locale_id":       null,
    "locked":          true,
    "position":        4,
    "forum_type":      "articles",
    "access":          "everybody",
    "created_at":      "2010-07-20T22:55:29Z",
    "updated_at":      "2012-03-05T10:38:52Z"
  }
}
```

### Create Forum
`POST /api/v2/forums.json`

#### Allowed For

 * Admins on non-enterprise accounts
 * Admins and agents with full forum access on enterprise accounts

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/forums.json \
  -H "Content-Type: application/json" -X POST \
  -d '{"forum": {"name": "My Forum", "forum_type": "articles", "access": "logged-in users" }}' \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/forums/{id}.json

{
  "forum": {
    "id":              354882,
    "name":            "My Forum",
    "description:":    null,
    "category_id":     null,
    "organization_id": null,
    "locale_id":       null,
    "locked":          false,
    "position":        9999,
    "forum_type":      "articles",
    "access":          "logged-in users",
    "created_at":      "2012-03-05T10:38:52Z",
    "updated_at":      "2012-03-05T10:38:52Z"
  }
}
```

### Update Forum
`PUT /api/v2/forums/{id}.json`

#### Allowed For

 * Admins on non-enterprise accounts
 * Admins and agents with full forum access on enterprise accounts

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/forums/{id}.json \
  -H "Content-Type: application/json" -d '{"forum": {"name": "The Forum"}}' \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response

```http
Status: 200 OK

{
  "forum": {
    "id":              354882,
    "name":            "The Forum",
    "description:":    null,
    "category_id":     null,
    "organization_id": null,
    "locale_id":       null,
    "locked":          false,
    "position":        9999,
    "forum_type":      "articles",
    "access":          "logged-in users",
    "updated_at":      "2012-03-05T10:38:52Z",
    "updated_at":      "2012-03-10T04:28:11Z"
  }
}
```

### Delete Forum
`DELETE /api/v2/forums/{id}.json`

#### Allowed For

 * Admins on non-enterprise accounts
 * Admins and agents with full forum access on enterprise accounts

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/forums/{id}.json \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```
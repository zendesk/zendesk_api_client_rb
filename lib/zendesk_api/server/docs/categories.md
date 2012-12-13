## Categories

### JSON Format
Categories are represented as simple flat JSON objects which have the following keys:

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned during creation
| url             | string  | yes       | no        | The API url of this category
| name            | string  | no        | yes       | The name of the category
| description     | string  | no        | no        | The description of the category
| position        | integer | no        | no        | The position of this category relative to other categories
| created_at      | date    | yes       | no        | The time the category was created
| updated_at      | date    | yes       | no        | The time of the last update of the category

#### Example
```js
{
  "id":              35436,
  "url":             "https://company.zendesk.com/api/v2/categories/35436.json",
  "name":            "Self Help Articles",
  "description":     null,
  "position":        21,
  "created_at":      "2009-07-20T22:55:29Z",
  "updated_at":      "2011-05-05T10:38:52Z"
}
```

### List Categories
`GET /api/v2/categories.json`

#### Availability

Accounts that have forum categories

#### Allowed For:

 * Admins on non-enterprise accounts
 * Admins and agents with full forum access on enterprise accounts

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/categories.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "categories": [
    {
      "id":              35436,
      "name":            "Self Help Articles",
      "description":     null,
      "position":        21,
      "created_at":      "2009-07-20T22:55:29Z",
      "updated_at":      "2011-05-05T10:38:52Z"
    },
    {
      "id":              12,
      "name":            "News",
      "description":     "Announcements about routine maintenance, scheduled downtime, and new features.",
      "position":        28,
      "created_at":      "2011-07-20T04:31:29Z",
      "updated_at":      "2012-02-02T10:32:59Z"
    }
  ]
}
```

### Show Category
`GET /api/v2/categories/{id}.json`

#### Allowed For

 * Admins
 * Anyone who can access at least one forum in the category

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/categories/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "category": {
    "id":              12,
    "name":            "News",
    "description":     "Announcements about routine maintenance, scheduled downtime, and new features.",
    "position":        28,
    "created_at":      "2011-07-20T04:31:29Z",
    "updated_at":      "2012-02-02T10:32:59Z"
  }
}
```

### Create Category
`POST /api/v2/categories.json`

#### Allowed For

 * Admins on non-enterprise accounts
 * Admins and agents with full forum access on enterprise accounts

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/categories.json \
  -H "Content-Type: application/json" -d '{"category": {"name": "My Category"}}' \
  -v -u {email_address}:{password} -X POST
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/categories/{id}.json

{
  "category": {
    "id":              14215,
    "name":            "My Category",
    "description":     null,
    "position":        9999,
    "created_at":      "2012-02-02T04:31:29Z",
    "updated_at":      "2012-02-02T04:31:29Z"
  }
}
```

### Update Category
`PUT /api/v2/category/{id}.json`

#### Allowed For

 * Admins on non-enterprise accounts
 * Admins and agents with full forum access on enterprise accounts

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/categories/{id}.json \
  -H "Content-Type: application/json" -d '{"category": {"name": "The Category About Nothing"}}' \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response

```http
Status: 200 OK

{
  "category": {
    "id":              14215,
    "name":            "The Category About Nothing",
    "description":     null,
    "position":        9999,
    "created_at":      "2012-02-02T04:31:29Z",
    "updated_at":      "2012-03-10T14:51:08Z"
  }
}
```

### Delete Category
`DELETE /api/v2/categories/{id}.json`

#### Allowed For

 * Admins on non-enterprise accounts
 * Admins and agents with full forum access on enterprise accounts

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/categories/{id} \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```
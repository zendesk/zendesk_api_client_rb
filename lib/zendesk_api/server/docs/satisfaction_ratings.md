## Satisfaction Ratings

If you have enabled satisfaction ratings for your account, this end point allows you to quickly retrieve all ratings.

### JSON Format

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned upon creation
| url             | string  | yes       | no        | The API url of this rating
| assignee_id     | integer | yes       | yes       | The id of agent assigned to at the time of rating
| group_id        | integer | yes       | yes       | The id of group assigned to at the time of rating
| requester_id    | integer | yes       | yes       | The id of ticket requester submitting the rating
| ticket_id       | integer | yes       | yes       | The id of ticket being rated
| score           | string  | yes       | yes       | The rating: "offered", "unoffered", "good" or "bad"
| created_at      | date    | yes       | no        | The time the satisfaction rating got created
| updated_at      | date    | yes       | no        | The time the satisfaction rating got updated
| comment         | string  | yes       | no        | The comment received with this rating, if available

#### Example
```js
{
  "id":              35436,
  "url":             "https://company.zendesk.com/api/v2/satisfaction_ratings/62.json",
  "assignee_id":     135,
  "group_id":        44,
  "requester_id":    7881,
  "ticket_id":       208,
  "score":           "good",
  "updated_at":      "2011-07-20T22:55:29Z",
  "created_at":      "2011-07-20T22:55:29Z"
}
```

### List Satisfaction Ratings
`GET /api/v2/satisfaction_ratings.json`

Lists all received satisfaction rating requests ever issued for your account. To only list
the satisfaction ratings submitted by your customers, use the "received" end point below instead.

#### Allowed For:

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/satisfaction_ratings.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "satisfaction_ratings": [
    {
      "id":              35436,
      "url":             "https://company.zendesk.com/api/v2/satisfaction_ratings/35436.json",
      "assignee_id":     135,
      "group_id":        44,
      "requester_id":    7881,
      "ticket_id":       208,
      "score":           "good",
      "updated_at":      "2011-07-20T22:55:29Z",
      "created_at":      "2011-07-20T22:55:29Z",
      "comment":         "Awesome support!"
    },
    {
      "id":              120447,
      ...
      "created_at":      "2012-02-01T04:31:29Z",
      "updated_at":      "2012-02-02T10:32:59Z"
    }
  ]
}
```


### List Received Satisfaction Ratings
`GET /api/v2/satisfaction_ratings/received.json`

Lists ratings provided by customers.

#### Allowed For:

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/satisfaction_ratings/received.json \
  -v -u {email_address}:{password}
```

#### Example Response

As above.


### Show Satisfaction Rating
`GET /api/v2/satisfaction_ratings/{id}.json`

#### Allowed For:

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/satisfaction_ratings/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "satisfaction_rating": {
    "id":              35436,
    "url":             "https://company.zendesk.com/api/v2/satisfaction_ratings/35436.json",
    "assignee_id":     135,
    "group_id":        44,
    "requester_id":    7881,
    "ticket_id":       208,
    "score":           "good",
    "updated_at":      "2011-07-20T22:55:29Z",
    "created_at":      "2011-07-20T22:55:29Z",
    "comment":         { ... }
  }
}
```

### Create a Satisfaction Rating
`POST /api/v2/tickets/{ticket_id}/satisfaction_rating.json`

#### Allowed For:

 * Requester of the ticket

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{ticket_id}/satisfaction_rating.json \
  -X POST -d '{"satisfaction_rating": {"score": "good", "comment": "Awesome support."}}' \
  -v -u {email_address}:{password} -H "Content-Type: application/json"
```

#### Example Response

```http
Status: 200 OK

{
  "satisfaction_rating": {
    "id":              35436,
    "url":             "https://company.zendesk.com/api/v2/satisfaction_ratings/35436.json",
    "assignee_id":     135,
    "group_id":        44,
    "requester_id":    7881,
    "ticket_id":       208,
    "score":           "good",
    "updated_at":      "2011-07-20T22:55:29Z",
    "created_at":      "2011-07-20T22:55:29Z",
    "comment":         { ... }
  }
}
```
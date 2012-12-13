## Tags

### List Tags
`GET /api/v2/tags.json`

Lists the most popular recent tags in decreasing popularity

#### Allowed For:

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tags.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "tags": [
    {
      "name":  "important",
      "count": 47
    },
    {
      "name":  "customer",
      "count": 11
    }
  ]
}
```

### Show Tags
`GET /api/v2/tickets/{id}/tags.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{id}/tags.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "tags": [
    "important",
    "customer"
  ]
}
```

### Set Tags
`POST /api/v2/tickets/{id}/tags.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{id}/tags.json \
  -v -u {email_address}:{password} -X POST \
  -d '{ "tags": ["important"] }'
```

#### Example Response

```http
Status: 200 OK

{
  "tags": [
    "important"
  ]
}
```

### Add Tags
`PUT /api/v2/tickets/{id}/tags.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{id}/tags.json \
  -v -u {email_address}:{password} -X PUT \
  -d '{ "tags": ["customer"] }'
```

#### Example Response

```http
Status: 200 OK

{
  "tags": [
    "important",
    "customer"
  ]
}
```

### Remove Tags
`DELETE /api/v2/tickets/{id}/tags.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{id}/tags.json \
  -v -u {email_address}:{password} -X DELETE \
  -d '{ "tags": ["customer"] }'
```

#### Example Response

```http
Status: 200 OK

{
  "tags": [
    "important"
  ]
}
```

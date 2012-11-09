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

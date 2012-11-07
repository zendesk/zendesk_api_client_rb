## Locales

### List Locales
`GET /api/v2/locales.json`

This lists the translation locales that are available for the account.

#### Allowed For:

 * Anyone

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/locales.json \
   -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "locales": [
    {
      "id":              1,
      "url":             "https://company.zendesk.com/api/v2/locales/1.json",
      "locale":          "en-US",
      "name":            "English",
      "created_at":      "2009-07-20T22:55:29Z",
      "updated_at":      "2011-05-05T10:38:52Z"
    },
    {
      "id":              8,
      "url":             "https://company.zendesk.com/api/v2/locales/8.json",
      "locale":          "de",
      "name":            "Deutsch",
      "created_at":      "2010-12-23T12:45:22Z",
      "updated_at":      "2012-04-01T10:44:12Z"
    }
  ]
}
```

### List Locales
`GET /api/v2/locales/agent.json`

This lists the translation locales that have been localized for agents.

#### Allowed For:

 * Anyone

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/locales/agent.json \
   -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "locales": [
    {
      "id":              1,
      "url":             "https://company.zendesk.com/api/v2/locales/1.json",
      "locale":          "en-US",
      "name":            "English",
      "created_at":      "2009-07-20T22:55:29Z",
      "updated_at":      "2011-05-05T10:38:52Z"
    },
    {
      "id":              8,
      "url":             "https://company.zendesk.com/api/v2/locales/8.json",
      "locale":          "de",
      "name":            "Deutsch",
      "created_at":      "2010-12-23T12:45:22Z",
      "updated_at":      "2012-04-01T10:44:12Z"
    }
  ]
}
```

### Show Locale
`GET /api/v2/locales/{id}.json`

#### Allowed For

 * Anyone

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/locales/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "locale": {
    "id":              8,
    "url":             "https://company.zendesk.com/api/v2/locales/8.json",
    "locale":          "de",
    "name":            "Deutsch",
    "created_at":      "2010-12-23T12:45:22Z",
    "updated_at":      "2012-04-01T10:44:12Z",
  }
}
```

### Show Current Locale
`GET /api/v2/locales/current.json`

This works exactly like show, but instead of taking an id as argument, it renders the locale
of the user performing the request.

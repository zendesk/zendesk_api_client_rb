## Sharing Agreements

### JSON Format
Sharing Agreements have the following format:

| Name            | Type                              | Comment
| --------------- | --------------------------------- | -------
| id              | integer                           | Automatically assigned upon creation
| name            | string                            | Name of this sharing agreement
| type            | string                            | Can be one of the following: inbound, outbound
| partner_name    | string                            | Can be one of the following: jira, null
| status          | string                            | Can be one of the following: accepted, declined, pending, inactive
| created_at      | date                              | The time the record was created

#### Example
```js
{
  "id":         88335,
  "url":        "https://company.zendesk.com/api/v2/agreements/88335.json",
  "name":       "Ticket Sharing",
  "type":       "inbound",
  "status":     "accepted",
  "created_at": "2012-02-20T22:55:29Z"
}
```

### List Sharing Agreements
`GET /api/v2/sharing_agreements.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/sharing_agreements.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "sharing_agreements": [
    {
      "id":    1,
      "name":  "Foo @ Zendesk",
      "type":  "inbound",
      ...
     },
    ...
  ]
}
```
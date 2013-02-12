## Organizations

Just as agents can be segmented into Groups in Zendesk, your customers (end-users) can be segmented into Organizations.  You can manually assign customers to an Organization or automatically assign them to an Organization by their email address domain.  Organizations can be used in business rules to route Tickets to Groups of agents or send special email notifications.

### JSON Format
Organizations are represented as simple flat JSON objects which have the following keys:

| Name            | Type    | Read-only | Mandatory | Comment
| --------------- | ------- | --------- | --------- | -------
| id              | integer | yes       | no        | Automatically assigned when creating organization
| external_id     | string  | no        | no        | A unique external id, you can use this to associate organizations to an external record
| name            | string  | no        | yes       | The name of the organization
| created_at      | date    | yes       | no        | The time the organization was created
| updated_at      | date    | yes       | no        | The time of the last update of the organization
| domain_names    | array   | no        | no        | An array of domain names associated with this organization
| details         | string  | no        | no        | In this field you can store any details obout the organization. e.g. the address
| notes           | string  | no        | no        | In this field you can store any notes you have about the organization
| group_id        | integer | no        | no        | New tickets from users in this organization will automatically be put in this group
| shared_tickets  | boolean | no        | no        | End users in this organization are able to see eachother's tickets
| shared_comments | boolean | no        | no        | End users in this organization are able to see eachother's comments on tickets
| tags            | array   | no        | no        | The tags of the organization

#### Example
```js
{
  "id":              35436,
  "external_id":     "ABC123",
  "url":             "https://company.zendesk.com/api/v2/organizations/35436.json",
  "name":            "One Organization",
  "created_at":      "2009-07-20T22:55:29Z",
  "updated_at":      "2011-05-05T10:38:52Z",
  "domain_names":    ["example.com", "test.com"],
  "details":         "This is a kind of organization",
  "notes":           "",
  "group_id":        null,
  "shared_tickets":  true,
  "shared_comments": true,
  "tags":            ["enterprise", "other_tag"]
}
```

### Listing Organizations
`GET /api/v2/organizations.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/organizations.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "organizations": [
    {
      "id":   35436,
      "name": "One Organization",
      ...
    },
    {
      "id":   20057623,
      "name": "Other Organization",
      ...
    },
  ]
}
```

### Autocomplete Organizations
`POST /api/v2/organizations/autocomplete.json?name={name}`

Returns an array of organizations whose name starts with the value specified
in the `name` parameter. The name must be at least 2 characters in length.

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/organizations/autocomplete.json \
  -X POST -d '{"name": "imp"}' -H "Content-Type: application/json" \
  -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "organizations": [
    {
      "id":   35436,
      "name": "Important Customers",
      ...
    },
    {
      "id":   20057623,
      "name": "Imperial College",
      ...
    },
  ]
}
```

### Getting Organizations
`GET /api/v2/organizations/{id}.json`

#### Allowed For

 * Admins
 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/organizations/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "organization": {
    {
      "id":   35436,
      "name": "My Organization",
      ...
    }
  }
}
```

### Creating Organizations
`POST /api/v2/organizations.json`

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/organizations.json \
  -H "Content-Type: application/json" -d '{"organization": {"name": "My Organization"}}' \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/organizations/{id}.json

{
  "organization": {
    {
      "id":   35436,
      "name": "My Organization",
      ...
    }
  }
}
```

### Create Many Organizations
`POST /api/v2/organizations/create_many.json`

#### Allowed For

 * Agents, restrictions apply on certain actions

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/organizations/create_many.json \
  -H "Content-Type: application/json" -X POST -d '{"organizations": [{"name": "Org1"}, {"name": "Org2"}]}'
```

#### Example Response

See [Job Status](job_statuses.md#show-job-status)

### Updating Organizations
`PUT /api/v2/organizations/{id}.json`

#### Allowed For

 * Admins

#### Example Request

```js
"organization": {
  "notes": "Something interesting"
}
```

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/organizations/{id}.json \
  -d '{"organization": {"notes": "Something interesting"}}' \
  -v -u {email_address}:{password} -H "Content-Type: application/json"
```

#### Example Response

```http
Status: 200 OK

{
  "organization": {

    "id":    35436,
    "name":  "My Organization",
    "notes": "Something interesting",
    ...
  }
}
```

### Deleting Organizations
`DELETE /api/v2/organizations/{id}.json`

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/organizations/{id}.json \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```

### Search Organizations
`GET /api/v2/organizations/search.json?external_id={external_id}`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/search.json?external_id={search term} \
  -v -u {email_address}:{password}
```

#### Example Response

See [Listing Organizations](#listing-organizations)
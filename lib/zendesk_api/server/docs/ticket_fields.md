## Ticket Fields

Zendesk allows admins to customize fields that display on the ticket form.  Basic text fields as well as customizable dropdown and number fields are available.  The visibility of these fields can be customized for end-users in the portal interface as well as to agent interfaces.

### JSON Format
Ticket fields have the following attributes

| Name                  | Type    | Read-only | Mandatory | Comment
| --------------------- | ------- | --------- | --------- | -------
| id                    | integer | yes       | no        | Automatically assigned upon creation
| url                   | string  | yes       | no        | The URL for this resource
| type                  | string  | no        | yes       | The type of the ticket field
| title                 | string  | no        | yes       | The title of the ticket field
| description           | string  | no        | no        | The description of the purpose of this ticket field, shown to users
| position              | integer | no        | no        | A relative position for the ticket fields, determines the order of ticket fields on a ticket
| active                | boolean | no        | no        | Whether this field is available
| required              | boolean | no        | no        | If it's required for this field to have a value when updated by agents
| collapsed_for_agents  | string  | no        | no        | If this field should be shown to agents by default or be hidden alongside infrequently used fields
| regexp_for_validation | string  | no        | no        | Regular expression field only. The validation pattern for a field value to be deemed valid.
| title_in_portal       | string  | no        | no        | The title of the ticket field when shown to end users
| visible_in_portal     | boolean | no        | no        | Whether this field is available to end users
| editable_in_portal    | boolean | no        | no        | Whether this field is editable by end users
| required_in_portal    | boolean | no        | no        | If it's required for this field to have a value when updated by end users
| tag                   | string  | no        | no        | A tag value to set for checkbox fields when checked
| created_at            | date    | yes       | no        | The time the ticket field was created
| updated_at            | date    | yes       | no        | The time of the last update of the ticket field
| custom_field_options  | array   | no        | yes       | Required and presented for a ticket field of type "tagger"

#### Example
```js
{
  "id":                    34,
  "url":                   "https://company.zendesk.com/api/v2/ticket_fields/34.json",
  "type":                  "subject",
  "title":                 "Subject",
  "description":           "This is the subject field of a ticket",
  "position":              21,
  "active":                true,
  "required":              true,
  "collapsed_for_agents":  false,
  "regexp_for_validation": null,
  "title_in_portal":       "Subject",
  "visible_in_portal":     true,
  "editable_in_portal":    true,
  "required_in_portal":    true,
  "tag":                   null,
  "created_at":            "2009-07-20T22:55:29Z",
  "updated_at":            "2011-05-05T10:38:52Z"
}
```

### List Ticket Fields
`GET /api/v2/ticket_fields.json`

 Returns a list of all ticket fields in your account. Fields are returned in the order that you specify
 in your Ticket Fields configuration in Zendesk. Clients should cache this resource for the duration of
 their API usage and map the id for each ticket field to the values returned under the
 fields attributes on the [Ticket](tickets.md) resource.

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/ticket_fields.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "ticket_fields": [
    {
      "id":                    34,
      "url":                   "https://company.zendesk.com/api/v2/ticket_fields/34.json",
      "type":                  "subject",
      "title":                 "Subject",
      "description":           "This is the subject field of a ticket",
      "position":              21,
      "active":                true,
      "required":              true,
      "collapsed_for_agents":  false,
      "regexp_for_validation": null,
      "title_in_portal":       "Subject",
      "visible_in_portal":     true,
      "editable_in_portal":    true,
      "required_in_portal":    true,
      "tag":                   null,
      "created_at":            "2009-07-20T22:55:29Z",
      "updated_at":            "2011-05-05T10:38:52Z"
    }
  ]
}
```


### Show Ticket Field
`GET /api/v2/ticket_fields/{id}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/ticket_fields/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "ticket_field": {
    "id":                    34,
    "url":                   "https://company.zendesk.com/api/v2/ticket_fields/34.json",
    "type":                  "subject",
    "title":                 "Subject",
    "description":           "This is the subject field of a ticket",
    "position":              21,
    "active":                true,
    "required":              true,
    "collapsed_for_agents":  false,
    "regexp_for_validation": null,
    "title_in_portal":       "Subject",
    "visible_in_portal":     true,
    "editable_in_portal":    true,
    "required_in_portal":    true,
    "tag":                   null,
    "created_at":            "2009-07-20T22:55:29Z",
    "updated_at":            "2011-05-05T10:38:52Z"
  }
}
```

### Create Ticket Fields
`POST /api/v2/ticket_fields.json`

 Types of custom fields that can be created are:

 * `text` (default when no "type" is specified)
 * `textarea`
 * `checkbox`
 * `date`
 * `integer`
 * `decimal`
 * `regexp`
 * `tagger` (custom dropdown)

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/ticket_fields.json \
  -H "Content-Type: application/json" -X POST \
  -d '{"ticket_field": {"type": "text", "title": "Age"}}' \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/ticket_fields/{id}.json

{
  "ticket_field": {
    "id":                    89,
    "url":                   "https://company.zendesk.com/api/v2/ticket_fields/89.json",
    "type":                  "text",
    "title":                 "Age",
    "description":           "Age",
    "position":              9999,
    "active":                true,
    "required":              true,
    "collapsed_for_agents":  false,
    "regexp_for_validation": null,
    "title_in_portal":       "Age",
    "visible_in_portal":     false,
    "editable_in_portal":    false,
    "required_in_portal":    false,
    "tag":                   null,
    "created_at":            "2012-04-02T22:55:29Z",
    "updated_at":            "2012-04-02T22:55:29Z"
  }
}
```

### Update Ticket Fields
`PUT /api/v2/ticket_fields/{id}.json`

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/ticket_fields/{id}.json \
  -H "Content-Type: application/json" -X PUT \
  -d '{ "ticket_field": { "title": "Your age" }}' \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK
Location: https://{subdomain}.zendesk.com/api/v2/ticket_fields/89.json

{
  "ticket_field": {
    "id":                    89,
    "url":                   "https://company.zendesk.com/api/v2/ticket_fields/89.json",
    "type":                  "text",
    "title":                 "Your age",
    "description":           "Your age",
    "position":              9999,
    "active":                true,
    "required":              true,
    "collapsed_for_agents":  false,
    "regexp_for_validation": null,
    "title_in_portal":       "Your age",
    "visible_in_portal":     false,
    "editable_in_portal":    false,
    "required_in_portal":    false,
    "tag":                   null,
    "created_at":            "2012-04-02T22:55:29Z",
    "updated_at":            "2012-04-02T23:11:23Z"
  }
}
```

### Updating a Custom Dropdown (Tagger) Field

Updating a custom dropdown field replaces the ticket field options.  Pass all options that you require in the ticket field.

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/ticket_fields/{id}.json \
  -H "Content-Type: application/json" -X PUT \
  -d '{"ticket_field": {"custom_field_options": [{"name": "Option 1", "value": "option_1"}, {"name": "Option 2","value": "option_2"}]}}' \
  -v -u {email_address}:{password}
```


### Delete Ticket Field
`DELETE /api/v2/ticket_fields/{id}.json`

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v1/ticket_fields/{id}.json \
  -v -u {email_address}:{password} -X DELETE
```

#### Example Response

```http
Status: 200 OK
```

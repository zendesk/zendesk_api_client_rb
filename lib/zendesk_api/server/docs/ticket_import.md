## Ticket Import

This end-point is for bulk importing tickets. It will allow you to move data from legacy systems into Zendesk. We do not run triggers or the likes during bulk imports like these.

### Ticket Import
`POST /api/v2/imports/tickets.json`

#### Allowed For

 * Admins

#### Request Parameters

 * ticket: a hash holding the parameters for the ticket

```js
{
  "ticket": {
    "requester_id": 827,
    "assignee_id": 19,
    "subject": "Some subject",
    "description": "A description",
    "tags": [ "foo", "bar" ],
    "comments": [
      { "author_id": 827, "value": "This is a comment", "created_at": "2009-06-25T10:15:18Z" },
      { "author_id": 19, "value": "This is a private comment", "public": false }
    ]
  }
}
```

In addition to the parameters that we generally accept for a ticket, the import also allows
you to set the following time stamps on the ticket being imported: `solved_at`, `updated_at`, `created_at`

Handling attachments is done the same way as in the regular tickets API, you upload the files first
and supply the token needed in the comment parameters.

No triggers will be run on tickets imported in this fashion and hence there will not be any detailed
ticket metrics to report on for these kinds of tickets. We recommend you set a tag to signify that these
tickets were added to Zendesk using bulk import.

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/imports/tickets.json \
  -v -u {email_address}:{password} -X POST
  -d '{"ticket": {"subject": "Help", "comments": [{ "author_id": 19, "value": "This is a comment" }]}}'
```

#### Example Response

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/tickets/{id}.json

{
  "ticket": {
    {
      "id":      35436,
      "subject": "Help",
      ...
    }
  }
}
```
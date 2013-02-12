## Views

A view consists of one or more conditions that define a collection of tickets to display. If the conditions are met, the ticket is included in the view. For example, a view can display all open tickets that were last updated more than 24 hours ago.

For more information, see [Using views to manage ticket workflow](https://support.zendesk.com/entries/20103667).


### JSON Format
Views are represented as simple flat JSON objects which have the following keys.

| Name            | Type                       | Comment
| --------------- | ---------------------------| -------------------
| id              | integer                    | Automatically assigned when created
| title           | string                     | The title of the view
| active          | boolean                    | Useful for determining if the view should be displayed
| restriction     | object                     | Who may access this account. Will be null when everyone in the account can access it.
| execution       | [Execute](#execution)      | An object describing how the view should be executed
| conditions      | [Conditions](#conditions)  | An object describing how the view is constructed
| created_at      | date                       | The time the view was created
| updated_at      | date                       | The time of the last update of the view

#### Example
```js
{
  "view": {
    "id": 25,
    "title": "Tickets updated <12 Hours",
    "active": true,
    "execution": { ... },
    "conditions": [ ... ],
    "restriction": {
      "type": "User",
      "id": 4
    }
  }
}
```

### Execution
View Execution is a read-only object that describes how to display a collection of tickets in a View.

| Name            | Type    | Comment
| --------------- | ------- | -------
| columns         | Array   | The ticket fields to display. Custom fields have an id, title, type and url referencing the [Ticket Field](ticket_fields.md)
| group           | Object  | When present, the structure indicating how the tickets are grouped
| sort            | Object  | The column structure of the field used for sorting.

#### Example
```js
{
   "execution":{
     "columns": [
       { "id": "status",  "title": "Status" },
       { "id": "updated", "title": "Updated" },
       {
         "id": 5, "title": "Account", "type": "text",
         "url": "https://example.zendesk.com/api/v2/ticket_fields/5.json"
       },
       ...
     ]
     "group": { "id": "status", "title": "Status", "order": "desc" },
     "sort": { "id": "updated", "title": "Updated", "order": "desc" }
   }
}
```

### Conditions
The conditions under which a ticket is selected.

| Name         | Type    | Comment
| ------------ | ------- | -------
| all          | array   | Tickets must fulfill *all* of these conditions to be considered matching
| any          | array   | Tickets may satisfy *any* of these conditions to be considered matching

#### Example
```js
{
   "conditions": {
     "all": [
       { "field": "status", "operator": "less_than", "value": "solved" },
       { "field": "assignee", "operator": "is", "value": "me" },
     ],
     "any": [
     ]
   }
}
```

<!---

### View Rows

View Rows are read-only and represented as simple flat JSON objects which have the following keys.

| Name            | Type                        | Comment
| --------------- | --------------------------- | -------------------
| view            | Array                       | View that was executed. Consists of id and url.
| rows            | Array                       | Array of tickets contained in the view, described by the fields.
| columns         | Array                       | Array of [Fields](#execution) and [Custom Fields](#execution) representing the columns in each row.

A row contains the data indicated by the idenitifiers in the columns array.

| Name                   | Type                         | Optional  | Comment
| ---------------------- | ---------------------------- | --------- | ----------------
| ticket                 | Object                       | no        | Ticket id, url, subject, description, status, type, priority and comment this row is a subset of.
| custom_fields          | Array                        | no        | Custom fields values.
| group                  | Integer                      | yes       | Id of this ticket's group.
| organization           | Integer                      | yes       | Id of this ticket's organization.
| requester              | Integer                      | yes       | Id of this ticket's requester.
| assignee               | Integer                      | yes       | Id of this ticket's assignee.
| submitter              | Integer                      | yes       | Id of this ticket's submitter.
| locale                 | String                       | yes       | Locale of the requester.
| type                   | String                       | yes       | See [Ticket](tickets.md#json-format)
| priority               | String                       | yes       | See [Ticket](tickets.md#json-format)
| status                 | String                       | yes       | See [Ticket](tickets.md#json-format)
| updated_by_type        | String                       | yes       | Last updated by 'agent' or 'end user'
| subject                | DateTime                     | yes       | Ticket subject.
| requester_updated_at   | DateTime                     | yes       | When the requester last updated the ticket.
| assignee_updated_at    | DateTime                     | yes       | When the assignee last updated the ticket.
| assigned               | DateTime                     | yes       | When the ticket was assigned last.
| due_date               | DateTime                     | yes       | When the ticket is due.
| solved                 | DateTime                     | yes       | When the ticket was solved.
| created                | DateTime                     | yes       | When the ticket was created.
| updated                | DateTime                     | yes       | When the ticket was updated.

#### Example
```js
{
  "view": {
    "id": 5,
    "url": "https://example.zendesk.com/api/v2/views/5.json"
  },
  "rows": [
    {
      "ticket": { ... },
      "locale": "en-US",
      "group": { ... },
      ...
    },
    ...
  ],
  "columns": [
    {
      "id": "locale",
      "title": "Locale"
    },
    {
      "id": 5,
      "title": "Account",
      "url": ...
    },
    ...
  ]
}
```

-->

### List Views
`GET /api/v2/views.json`

Lists shared and personal Views available to the current user

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/views.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "views": [
    {
      "id":25,
      "title":"Tickets updated <12 Hours",
      "active":true,
      "execution":{ ... },
      "conditions": { ... },
      "restriction":{ ... }
    },
    {
      "id":23,
      "title":"Unassigned tickets",
      "active":false,
      "execution":{ ... },
      "conditions": { ... },
      "restriction":{ ... }
    },
    ...
  ],
  "count": 7,
  "next_page": null,
  "previous_page": null
}
```

### List Active Views
`GET /api/v2/views/active.json`

Lists active shared and personal Views available to the current user

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/views/active.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "views": [
    {
      "id": 25,
      "title": "Tickets updated <12 Hours",
      "active": true
      "execution": { ... },
      "conditions": { ... },
      "restriction": { ... }
    },
    ...
  ],
  "count": 7,
  "next_page": null,
  "previous_page": null
}
```

### List Views - Compact
`GET /api/v2/views/compact.json`

A compacted list of shared and personal views available to the current user

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/views/compact.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "views": [
    {
      "id": 25,
      "title": "Tickets updated <12 Hours",
      "active": true
      "execution": { ... },
      "conditions": { ... },
      "restriction": { ... }
    },
    ...
  ],
  "count": 7,
  "next_page": null,
  "previous_page": null
}
```

### Getting Views
`GET /api/v2/views/{id}.json`

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/views/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "view": {
    "id": 25,
    "title": "Tickets updated <12 Hours",
    "active": true
    "execution": { ... },
    "conditions": { ... },
    "restriction": { ... }
  }
}
```

### Create View
`POST /api/v2/views.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/api/v2/views.json \
  -H "Content-Type: application/json" -X POST -d '{"view":{"title":"Roger Wilco", "all": [{ "field": "status", "operator": "is", "value": "open" }]}}'
```

#### Example Response

```http
Status: 201 Created
Location: /api/v2/view/{new-view-id}.json

{
  "view": {
    "id":   9873843,
    "title": "Roger Wilco",
    ...
  }
}
```

### Update View
`PUT /api/v2/view/{id}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl -v -u {email_address}:{password} https://{subdomain}.zendesk.com/view/{id}.json \
  -H "Content-Type: application/json" -X PUT -d '{"view":{"title":"Roger Wilco II"}}'
```

#### Example Response

```http
Status: 200 OK

{
  "view": {
    "id":   9873843,
    "title": "Roger Wilco II",
    ...
  }
}
```

### Executing Views
`GET /api/v2/views/{id}/execute.json`

You execute a view in order to get the tickets that fulfill the conditions of the view.

The view execution system is designed for periodic rather than high-frequency API usage. In particular, views that are called very
frequently by an API client (more often than once every 5 minutes on average) may be cached by our software. This means
that the API client will still receive a result however that result may have been computed at any time within the last 10
minutes.

If you are looking for a method to get the latest changes to your Zendesk via the API we recommend the ticket export API
which can be called as often as once a minute, and will return all the tickets changed since last poll.

View output sorting can be controlled by passing the sort_by and sort_order parameters in the
format described in the table under [view previewing](#previewing-views).

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/views/{id}/execute.json \
  -v -u {email_address}:{password}
```

With sort options:

 ```bash
curl https://{subdomain}.zendesk.com/api/v2/views/{id}/execute.json?sort_by=id&sort_order=desc \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "view": {
    "id": 25,
    "url": ...
  },
  "rows": [
    {
      "ticket": { ... },
      "locale": "en-US",
      "group": 1,
      ...
    },
    ...
  ],
  "columns": [
    {
      "id": "locale",
      "title": "Locale"
    },
    {
      "id": 5,
      "title": "Account",
      "url": ...
    },
    ...
  ],
 "groups": [ ... ]
}
```

### Getting Tickets from a view
`GET /api/v2/views/{id}/tickets.json`

#### Allowed For

 * Agents

#### Using curl:

```bash
curl https://{subdomain}.zendesk.com/api/v2/views/{id}/tickets.json \
  -v -u {email_address}:{password}
```

#### Example Responses

```http
Status: 200 OK

{
  "tickets": [
    {
      "id":      35436,
      "subject": "Help I need somebody!",
      ...
    },
    {
      "id":      20057623,
      "subject": "Not just anybody!",
      ...
    },
  ]
}
```

### Previewing Views
`POST /api/v2/views/preview.json`

Views can be previewed by constructing the conditions in the [proper format](#conditions) and nesting them under the 'view' key.
The output can also be controlled by passing in any of the following parameters and nesting them under the 'view' key.

| Name            | Type    | Comment
| --------------- | ------- | -------
| columns         | Array   | The ticket fields to display. System fields are looked up by name, custom fields by title or id.
| group_by        | String  | When present, the field by which the tickets are grouped
| group_order     | String  | The direction the tickets are grouped. May be one of 'asc' or 'desc'
| sort_order      | String  | The direction the tickets are sorted. May be one of 'asc' or 'desc'
| sort_by         | String  | The ticket field used for sorting. This will either be a title or a custom field id.

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/views/preview.json \
  -v -u {email_address}:{password} -X POST -H "Content-Type: application/json" \
  -d '{"view": {"all": [{"operator": "is", "value": "open", "field": "status"}], "output": {"columns": ["subject"]}}}'
```

#### Example Response

```http
Status: 200 OK

{
  "rows": [
    {
      "ticket": { ... },
      "subject": "en-US",
      ...
    },
    ...
  ],
  "columns": [
    {
      "id": "subject",
      "title": "Subject"
    },
    ...
  ]
}
```

### View Counts and Caching

The view count APIs allow an API consumer to estimate how many tickets remain in a View without having to retrieve the entire View.
These APIs are intended to help estimate View size; from a business perspective, accuracy becomes less relevant as your View size increases.
To ensure quality of service, these counts are cached more heavily as the number of tickets in a View grows.  For a View with thousands of tickets,
you can expect its count to be cached for 60-90 minutes and may not reflect the actual number of tickets in your View.

### View Counts
`GET /api/v2/views/count_many.json?ids={view_id},{view_id}`

Calculates the size of the view in terms of number of tickets the view will return.
Only returns values for personal and shared views accessible to the user performing
the request.

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/views/count_many.json?ids={view_id} \
  -v -u {email_address}:{password}
```

#### Example Response

When you retrieve view counts that are not "fresh", it's recommended to wait for a short
while an poll again for only the stale view counts.

```http
Status: 200 OK

{
  "view_counts": [{
    "view_id": 25,
    "url":     "https://company.zendesk.com/api/v2/views/25/count.json",
    "value":   719,
    "pretty":  "~700",
    "fresh":   true
  },
  {
    "view_id": 78,
    "url":     "https://company.zendesk.com/api/v2/views/78/count.json",
    "value":   null,
    "pretty":  "...",
    "fresh":   false
  }
]}
```

### View Count
`GET /api/v2/views/{id}/count.json`

Returns the ticket count for a single view.

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/views/{id}/count.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK
{
  "view_count": {
    "view_id": 25,
    "url":     "https://company.zendesk.com/api/v2/views/25/count.json",
    "value":   719,
    "pretty":  "~700",
    "fresh":   true
  }
}
```

### Exporting Views
`GET /api/v2/views/{id}/export.json`

Returns the csv attachment of the current view if possible.
Enqueues a job to produce the csv if needed.

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/views/{id}/export.json \
  -v -u {email_address}:{password}
```

#### Example Responses

##### With available data
```http
Status: 200
Content-Disposition: Attachment
[CSV data]
```

##### Starting a CSV job
```http
Status: 201

{
  "export": {
    "view_id": 25,
    "status": "starting"
  }
}
```
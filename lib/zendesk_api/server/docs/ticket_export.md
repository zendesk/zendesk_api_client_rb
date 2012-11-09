## Incremental Tickets

The incremental ticket API is designed for API consumers that want to know about tickets that changed in Zendesk "since you last asked".  It works something like this:

```
You: Hello Zendesk, give me the tickets since 0 o'clock
Us: Sure, here are the tickets up until, and including, 5 o'clock
You: Hello Zendesk, give me the tickets since 5 o'clock
Us: Sure, here are the tickets up until, and including, 7 o'clock
```

Because of this API behavior, the incremental ticket API is different in behavior, requirements and semantics than other API endpoints.  Most important to note is that **the ticket response returns a lightweight representation of each ticket and does not include comments**.  To retrieve the full ticket response, use our [Tickets API](tickets.html) to retrieve the full ticket.

Please study the docs below and the data you get in response.

### JSON Format
The tickets updated since a given point in time are represented as simple flat JSON objects with these attributes:

| Name                  | Type    | Read-only | Mandatory | Comment
| ---------------       | ------- | --------- | --------- | -------
| end_time              | date    | yes       | no        | The most recent time present in this result set in Unix epoch time; this should be used as the next start_time
| next_page             | string  | yes       | no        | The URL that should be called to get the next set of results
| results               | array   | yes       | no        | An array of hashes, one per ticket. Each hash contains key/value pairs corresponding to ticket attributes
| field_headers         | array   | yes       | no        | A hash of field keys and their human-readable names
| options               | hash    | yes       | no        | Contains the timezone of the account and the time offset in hours after midnight for the next sync

#### Example
```js
{
  "end_time": 1332034771,
  "next_page":"https://domain.zendesk.com/api/v2/exports/tickets.json?start_time=1332034771",
  "field_headers": {
    "group_name": "Group",
    "id": "Id",
    "created_at": "Created at",
    ...
  },
  "results": [
    {
      "group_name": "Support",
      "id": 2,
      "created_at": "2012-02-02T04:31:29Z",
      ...
     },
     ...
  ],

}
```

### Incremental Ticket Export
`GET /api/v2/exports/tickets.json`

#### Allowed For

 * Admins

#### Request Parameters

 * start_time: The time of the oldest ticket you are interested in. Tickets modified on or since this time will be returned.
 The start time is provided as the number of seconds since epoch UTC.

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/exports/tickets.json?start_time=1332034771 \
  -v -u {email_address}:{password}
```

#### Usage Notes

The API consumer should call this API to initially export a complete list of ticket details from a help desk,
and periodically poll the API to incrementally export ticket details for tickets that have been updated since
the previous poll. This API should not be used to frequently export a full list of all tickets.

This API does not protect against duplicate tickets, and in fact it will include plenty of duplicates,
as the query boils down to tickets whose updated time stamp is after or equal to the `start_time` parameter

Requests with start_time less than 5 minutes old will be rejected. You are only allowed to make 1 API call to this
API end point every 5 minute and we will return up to 1000 tickets per request. Please see the `sample` end point
below for an way to test this API without getting throttled continuiously. The rate limiting mechanism here
behaves identically to the one described in our [API introduction](introduction.md) and we recommend that you obey
the `Retry-After` header values as also elaborated in the [API introduction](introduction.md).

#### Example Response

```http
Status: 200 OK

{
  "end_time": 1332034771,
  "next_page":"https://domain.zendesk.com/api/v2/exports/tickets.json?start_time=1332034771",
  "field_headers": {
    "group_name": "Group",
    "id": "Id",
    "created_at": "Created at",
    ...
  },
  "results": [
    {
      "group_name": "Support",
      "id": 2,
      "created_at": "2012-02-02T04:31:29Z",
      ...
     },
     ...
  ]
}
```

### Sample Incremental Tickets

This end point is only to be used for testing the incremental export format. It is more relaxed in terms of
rate limiting, but will only return up to 50 records. Outside this, it's identical to the above API.

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/exports/tickets/sample.json?start_time=1332034771 \
  -v -u {email_address}:{password}
```
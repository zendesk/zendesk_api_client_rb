## Search

The search API is a unified search API that returns tickets, users, organizations, and forum topics.  Define filters to narrow your search results according to result type, date attributes, and object attributes such as ticket requester or tag.

### A few example queries

| Search query                                                 | Returns...
| ------------------------------------------------------------ | ----------
| status<solved requester:user@domain.com type:ticket          | All unsolved tickets requested by user@domain.com
| type:user tags:premium_support                               | All users tagged with ``premium_support``
| created>2012-06-17 type:ticket organization:"Mondocam Photo" | Tickets created within the Mondocam Photo organization after July 17, 2012

Our [search reference](https://support.zendesk.com/entries/20239737-zendesk-search-reference) offers a complete guide to all search filters available for advanced search.

### JSON Format
Queries are represented as JSON objects which have the following keys.

| Name                  | Type                 | Comment
| --------------------- | ---------------------| --------------------
| count                 | integer              | The total number of results matching this query
| next_page             | string               | URL to the next page of results
| prev_page             | string               | URL to the previous page of results
| results               | array                | May consist of Tickets, Users, Groups, Organizations, and Topics.  A ``result_type`` value is added to each result object and can have the following values: ``ticket``, ``user``, ``group``, ``organization``, ``topic``.

#### Example
```js
{
  "count":     1234,
  "next_page": "https://foo.zendesk.com/api/v2/search.json?query=\"type:Group hello\"&sort_by=created_at&sort_order=desc&page=2",
  "prev_page": null,
  "results": [
    {
      "name":        "Hello DJs",
      "created_at":  "2009-05-13T00:07:08Z",
      "updated_at":  "2011-07-22T00:11:12Z",
      "id":          211,
      "result_type": "group"
      "url":         "https://foo.zendesk.com/api/v2/groups/211.json"
    },
    {
      "name":        "Hello MCs",
      "created_at":  "2009-08-26T00:07:08Z",
      "updated_at":  "2010-05-13T00:07:08Z",
      "id":          122,
      "result_type": "group"
      "url":         "https://foo.zendesk.com/api/v2/groups/122.json"
    }
    ...
  ]
}
```

### Search
`GET /api/v2/search.json?query={search term}`

#### Available parameters

| Name                  | Type                | Required  | Comments
| --------------------- | --------------------| --------- | -------------------
| query                 | string              | yes       | The search text to be matched. Examples: "carrot potato", "'carrot potato'"
| sort_by               | string              | no        | Possible values are 'updated_at', 'created_at', 'priority', 'status', and 'ticket_type'
| sort_order            | string              | no        | One of 'relevance', 'asc', 'desc'. Defaults to 'relevance' when no 'order' criteria is requested.

#### Allowed For:

 * Logged in users

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/search.json?query={search term} \
  -v -u {email_address}:{password}
```

### Errors JSON Format
Errors are represented as JSON objects which have the following keys:

| Name                  | Type                 | Comment
| --------------------- | ---------------------| --------------------
| error                 | string               | The type of error. e.g.: 'unavailable', 'invalid'
| description           | string               |

#### Example
```js
{
  "error": "unavailable",
  "description": "Sorry, we could not complete your search query. Please try again in a moment."
}
```

### Anonymous search
`GET /api/v2/portal/search.json?query={search term}`

This resource behaves the same as /api/v2/search, but allows anonymous users to search public forums.

#### Allowed For:

 * Logged in users
 * Anonymous users on public forums

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/portal/search.json?query={search term} \
  -v -u {email_address}:{password}
```
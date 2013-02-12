## Introduction

Zendesk is a customer support platform that supports more than 20,000 businesses and 60 million customers in 140 countries around the globe. Many of these businesses use the Zendesk API to automate and enhance their customer support with Zendesk.

### The API
This is the documentation for the Zendesk v2 API. Read the introduction contents to understand how to be a good API citizen and to understand general restrictions and concerns.

When documenting a resource, we use curly braces for identifiers, like `{subdomain}` when talking about the URL for your Zendesk account, i.e. `https://{subdomain}.zendesk.com/api/v2/users/me.json`

### Change Policy

We reserves the right to add new attributes and resources to the API without advance notice. Breaking changes such as removing or renaming an attribute, may happen on an existing version of the API with two weeks notice and deprecation of attributes are tracked in our [Changes Roadmap](changes_roadmap.html). Major structural changes will only happen within the context of a version update.

### Security and Authentication

This API is an SSL-only API, regardless of how you may have your account configured. You can authorize against the API using either basic authentication with your username and password credentials, or with a username and API token.  This token is configurable in your Zendesk account under **Settings** > **Channels** > **API**.

### Rate Limiting

This API is rate limited; we only allow a certain number of requests per minute. We reserve the right to adjust the rate limit for given endpoints in order to provide a high quality of service for all clients. As an API consumer, you should expect to be able to make at least 200 requests per minute.

If the rate limit is exceeded, Zendesk will respond with a HTTP [429 Too Many Requests](http://tools.ietf.org/html/draft-nottingham-http-new-status-02#section-4) response code and a body that details the reason for the rate limiter kicking in. Further, the response will have a `Retry-After` header that tells you for how many seconds to sleep before retrying. You should anticipate this in your API client for the smoothest possible ride.

### Headers

This is a JSON-only API. You *must* supply a `Content-Type: application/json` header on `PUT` and `POST` operations. You *must* set a `Accept: application/json` header on all requests. You *may* get a `text/plain` response in case of error, e.g. in case of a bad request, you *should* treat this as an error you need to take action on.

### Common Response Structures

We respond to successful requests with HTTP status codes in the 200 or 300 range. When you create or update a resource, we will render the resulting JSON representation in the response body and set a `Location` header pointing to the resource, e.g:

```http
Status: 201 Created
Location: https://{subdomain}.zendesk.com/api/v2/items/123.json

{
  "item": {
    "id": 123,
    "url": "https://{subdomain}.zendesk.com/api/v2/items/123.json"
    "name": "Wibble",
    ...
    "created_at": "2012-04-04T09:14:57Z"
  }
}
```

Our time stamp format follows [ISO8601](http://en.wikipedia.org/wiki/ISO_8601) and we will always be serving UTC.

We respond to unsuccessful requests with HTTP status codes in the 400 range. The response *may* be content type `text/plain` for API level error messages (e.g. when trying to call the API without SSL). The response will be content type `application/json` for business level error messages. The latter contains a JSON hash with elaborate error messages to supplement the HTTP status code:

```js
{
  "details": {
    "value": [
      {
        "type": "blank",
        "description": "can't be blank"
      },
      {
        "type": "invalid",
        "description": " is not properly formatted"
      }
    ]
  },
  "description": "RecordValidation errors",
  "error": "RecordInvalid"
}
```

If you see a response from a known endpoint that looks like plain text, you've probably made a syntax error in your REST call. This is a common response if you try to make a request to a nonexistent Zendesk instance.

If you ever experience responses with status codes in the 500 range, Zendesk may be experiencing internal issues or having a scheduled maintenance (during which we send a `503 Service Unavailable` status code).

Please check [@zendeskops](https://twitter.com/zendeskops) and our [status page](http://www.zendesk.com/support/system-status) in such cases for any known issues.

When building an API client, we advice treating any `500` status codes as a warning/temporary state, if however, the status persists and we do not have an publicly announced maintenance or service disruption, then you should contact us at <a href="mailto:support@zendesk.com">support@zendesk.com</a> to initiate an investigation.

### Collections

Collections return a maximum of 100 records per page, and by default return 100 records per page. You can set this on a per request basis by passing e.g. `per_page=50` in the request parameters. You iterate the collection by incrementing the `page` attribute, e.g. `page=3`. Collections also include links in the response body for easier navigation, generally they are on this structure:

```js
{
  "users": [ ... ],
  "count": 1234,
  "next_page": "https://account.zendesk.com/api/v2/users.json?page=2",
  "previous_page": null
}
```

Stop paging when the `next_page` attribute is `null`.

Some collections can be ordered by transmitting a `sort_order=desc` or `sort_order=asc` parameter to the end point. Whether a specific collection can be ordered, is specified in the documentation for that specific resource.

### Side-loading (BETA)

Side-loading is an experimental feature that allows you to fetch associated data along with a resource (or resources) in a single request.

Normally, a request to `/tickets.json` will return ticket resources with a structure similar to:

```js
{
  "tickets": [
    {
      "requester_id": 7,
      ...
    },
    ...
  ]
}
```

To fetch the requester's data you must then make another request to `/users/7.json`.
Using side-loading, you can fetch a partial user resource along with the ticket in a single request. To make a side-load request,
add a comma-separated list of resources to load into the `include` parameter (e.g. `/tickets.json?include=users,groups` or `/tickets/1.json?include=users,groups`).

The response receieved will then include a top-level array of associated data under the appropriate resource key.

```js
{
  "tickets": [
    {
      "requester_id": 7,
      ...
    },
    ...
  ],
  "users": [
    {
      "id": 7,
      "name": "Bob Bobberson",
      ...
    }
  ]
}
```

| Resource                                                  | Available associations
| --------------------------------------------------------- | ---------------------------------------------------------------------------
| [Tickets](tickets.html)                                   | users, groups, organizations, last_audits, metric_sets, sharing_agreements
| [Audits](audits.html)                                     | users, organizations, groups, tickets
| [Users](users.html)                                       | organizations, abilities, roles, identities, groups
| [Groups](groups.html)                                     | users
| [Group Memberships](group_memberships.html)               | users, groups
| [Organizations](organizations.html)                       | abilities
| [View Execution / Previewing](views.html#executing-views) | The following are automatically side-loaded if applicable: group, organization, users
| [Topics](topics.html)                                     | users, forums
| [Topic Comments](topic_comments.html)                     | users
| [Requests](requests.html)                                 | The following are automatically side-loaded: users, organizations

**Warning: this is still experimental. If you encounter any issues, please contact <a href="mailto:support@zendesk.com">support@zendesk.com</a>. Please do not abuse this feature.**

### Official Zendesk API Clients and Guides

* [Ruby Client](https://github.com/zendesk/zendesk_api_client_rb)
* [PHP Quick Start Guide](https://support.zendesk.com/entries/21462093-php-and-zendesk-quick-start-guide)

### API Clients from the Zendesk Developer Community

* [Python Client Library by Eventbrite](https://github.com/eventbrite/zendesk)
* [.NET Client Library by Eric Neifert](https://github.com/eneifert/ZendeskApi_v2)
* [zendeskR by Basho Technologies (R)](https://github.com/tcash21/zendeskR)
* [node-zendesk by Farrin Reid (node.js)](https://github.com/blakmatrix/node-zendesk)

We welcome all contributions, please contact [support@zendesk.com](mailto:support@zendesk.com) to add your API client to the list.
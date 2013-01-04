## Ticket Audits

Audits are a **read-only** history of all updates to a ticket and the events that occur as a result of these updates.  When a Ticket is updated in Zendesk, we store an Audit.  Each Audit represents a single update to the Ticket, and each Audit includes a list of changes, such as:

* Changes to ticket fields
* Addition of a new comment
* Addition or removal of tags
* Notifications sent to Groups, Assignees, Requesters and CCs

To learn more about adding new comments to tickets, [see our Ticket documentation](tickets.html#updating-tickets).

### JSON Format
Audits are represented as JSON objects which have the following keys:

| Name       | Type                   | Read-only | Comment
| ---------- | ---------------------- | --------- | -------
| id         | integer                | yes       | Automatically assigned when creating audits
| ticket_id  | integer                | yes       | The ID of the associated ticket
| metadata   | hash                   | yes       | Metadata for the audit, custom and system data
| Via        | [Via](#the-via-object) | yes       | This object explains how this audit was created
| created_at | date                   | yes       | The time the audit was created
| author_id  | integer                | yes       | The user who created the audit
| events     | array                  | yes       | An array of the events that happened in this audit. See [Audit Events](#audit-events)

#### Example
```js
{
  "id":         35436,
  "ticket_id":  47,
  "created_at": "2009-07-20T22:55:29Z",
  "author_id":  35436,
  "metadata":  { "custom": { "time_spent": "3m22s" }, "system": { "ip_address": "184.106.40.75" }}
  "via": {
    "channel": "web"
  },
  "events": [
    {
      "id":          1564245,
      "type":        "Comment"
      "body":        "Thanks for your help!",
      "public":      true,
      "attachments": []
    },
    {
      "id":      1564246,
      "type":    "Notification"
      "subject": "Your ticket has been updated"
      "body":    "Ticket #47 has been updated"
    }
  ]
}
```

### Listing Audits
`GET /api/v2/tickets/{ticket_id}/audits.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{ticket_id}/audits.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "previous_page": null,
  "next_page": null,
  "count": 5,
  "audits": [
    {
      "created_at": "2011/09/25 22:35:44 -0700",
      "via": {
        "channel": "web"
      },
      "metadata": {
        "system": {
          "location": "San Francisco, CA, United States",
          "client": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.186 Safari/535.1",
          "ip_address": "76.218.201.212"
        },
        "custom": {
        }
      },
      "id": 2127301143,
      "ticket_id": 666,
      "events": [
        {
          "html_body": "<p>This is a new private comment</p>",
          "public": false,
          "body": "This is a new private comment",
          "id": 2127301148,
          "type": "Comment",
          "attachments": [
          ]
        },
        {
          "via": {
            "channel": "rule",
            "source": {
              "title": "Assign to first responder",
              "rel": "trigger",
              "id": 22472716,
              "type": "rule"
            }
          },
          "id": 2127301163,
          "value": "open",
          "type": "Change",
          "previous_value": "new",
          "field_name": "status"
        }
      ],
      "author_id": 5246746
    },
    ...
    {
      ...
      "events": [
        ...
      ],
    }
  ]
}
```

### Show Audit
`GET /api/v2/tickets/{ticket_id}/audits/{id}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{ticket_id}/audits/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response
```http
Status: 200 OK

{
  "audit": {
    "created_at": "2011/09/25 22:35:44 -0700",
    "via": {
      "channel": "web"
    },
    "metadata": {
      "system": {
        "location": "San Francisco, CA, United States",
        "client": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.186 Safari/535.1",
        "ip_address": "76.218.201.212"
      },
      "custom": {
      }
    },
    "id": 2127301143,
    "ticket_id": 666,
    "events": [
      {
        "html_body": "<p>This is a new private comment</p>",
        "public": false,
        "body": "This is a new private comment",
        "id": 2127301148,
        "type": "Comment",
        "attachments": []
      },
      {
        "via": {
          "channel": "rule",
          "source": {
            "title": "Assign to first responder",
            "rel": "trigger",
            "id": 22472716,
             "type": "rule"
          }
        },
        "id": 2127301163,
        "value": "open",
        "type": "Change",
        "previous_value": "new",
        "field_name": "status"
      }
    ],
    "author_id": 5246746
  }
}
```

### Marking an Audit as trusted
`PUT /api/v2/tickets/{ticket_id}/audits/{id}/trust.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{ticket_id}/audits/{id}/trust.json \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response
```http
Status: 200 OK
```

### Change a comment from public to private
`PUT /api/v2/tickets/{ticket_id}/audits/{id}/make_private.json`

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/tickets/{ticket_id}/audits/{id}/make_private.json \
  -v -u {email_address}:{password} -X PUT
```

#### Example Response
```http
Status: 200 OK
```

### The Via Object

The via object of a ticket audit or audit event tells you how or why the audit or event was created.
Via Objects can have the following keys:

| Name       | Type    | Comment
| ---------- | ------- | -------
| channel    | string  | This tells you how the ticket or event was created
| source     | object  | For some channels a source object gives more information about how or why the ticket or event was created

All via objects have a channel, but not all have a source. These are the different possible values for the channel and source values:

| channel      | source                              | Description
| ------------ | ------                              | -----------
| web          | none, feedback_tab or batch         | The ticket, audit, or event was created via the web interface
| email        | none                                | The ticket, audit, or event was created via email
| api          | none, ticket_sharing or import      | The ticket, audit, or event was created via the API
| rule         | none                                | The ticket, audit, or event was created via a trigger or automation
| forum        | none                                | The ticket, audit, or event was created via the forums
| twitter      | favorite, mention or direct_message | The ticket, audit, or event was created via Twitter
| chat         | none                                | The ticket, audit, or event was created via chat
| voice        | voicemail, inbound or outbound      | The ticket, audit, or event was created via a phone call
| sms          | none                                | The ticket, audit, or event was created via a text message
| facebook     | post or message                     | The ticket, audit, or event was created via Facebook
| system       | linked_problem, merge, follow_up    | The ticket, audit, or event was created by the system

### Audit Events

An Audit contains many Events.  These Events represent all activity which occurs on a Ticket, including public and private Comments, field changes, notifications send by business rule execution, and events which send notification to external services via our Targets framework.

If an Event has a different Via than its Audit, it will have its own Via object.

#### Ticket Comments
Comments represent the conversation between Requesters, Collaborators and Agents on a ticket. Comments can be public or private.

Ticket comments have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `Comment`
| body            | string  | yes       | The actual comment made by the author
| html_body       | string  | yes       | The actual comment made by the author formatted to HTML
| public          | boolean | yes       | If this is a public comment or an internal agents only note
| trusted         | boolean | yes       | If this comment is trusted or marked as being potentially fraudulent
| author_id       | integer | yes       | The id of the author of this comment
| attachments     | array   | yes       | The attachments on this comment as [Attachment](attachments.md) objects

#### Example
```js
{
  "id":        1274,
  "type":      "Comment"
  "body":      "Thanks for your help!",
  "public":    true,
  "author_id": 1,
  "attachments": [
    {
      "id":           498483,
      "name":         "crash.log",
      "content_url":  "https://company.zendesk.com/attachments/crash.log",
      "content_type": "text/plain",
      "size":         2532,
      "thumbnails":   []
    }
  ]
}
```

#### Ticket Voice Comments
Voice Comments are added to a ticket via our integrated Zendesk Voice feature.

Voice Comments have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `VoiceComment`
| data            | string  | yes       | A hash of properties about the call
| public          | boolean | yes       | If true, the ticket requester can see this comment
| formatted_from  | string  | yes       | A formatted version of the phone number which dialed the call
| formatted_to    | string  | yes       | A formatted version of the phone number which answered the call
| body            | string  | yes       | The actual comment made by the author
| html_body       | string  | yes       | The actual comment made by the author formatted to HTML
| public          | boolean | yes       | If this is a public comment or an internal agents only note
| trusted         | boolean | yes       | If this comment is trusted or marked as being potentially fraudulent
| author_id       | integer | yes       | The id of the author of this comment
| attachments     | array   | yes       | The attachments on this comment as [Attachment](attachments.md) objects

#### Example
```js
{
  "id":                    1274,
  "type":                  "VoiceComment"
  "body":                  "Thanks for your help!",
  "data":                  {
                             "from":                 "+14156973270",
                             "to":                   "+14129996294",
                             "recording_url":        "http//api.twilio.com/2010-04-01/Accounts/accountsid/Recordings/recording_sid",
                             "recording_duration":   "7",
                             "call_duration":        60,
                             "call_id":              171,
                             "answered_by_id":       6,            # not present for voicemails
                             "transcription_text":   "Hello",      # only present for voicemails with transcription enabled
                             "transcription_status": "completed",  # only present for voicemails with transcription enabled
                             "started_at":           2012-11-16 223622 UTC,
                             "location":             "San Francisco, California, United States",
                             "voice_transcription":  true,
                             "outbound":             false
                           },
  "formatted_from":        "+1 (123) 654-7890",
  "formatted_to":          "+1 (123) 325-7890",
  "transcription_visible": true,
  "public":                true,
  "author_id":             1,
  "body":                  "Request #219 "request" was closed and merged into this request.",
  "html_body":             "<p>Request <a target="_blank" href="/tickets/219">#219</a> &quot;aa&quot; was closed and merged into this request.</p>",
  "trusted":               true,
  "attachments":           []
}
```

#### Ticket Comment Privacy Change
If an Agent erroneously makes a public comment on a Ticket when they intended for it to be private, they can mark the comment as private.  This event tracks the fact that this occurred.

Ticket comment privacy change events have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `CommentPrivacyChange`
| comment_id      | integer | yes       | The id if the comment that changed privacy
| public          | boolean | yes       | Tells if the comment was made public or private

#### Example
```js
{
  "id":         1274,
  "type":       "CommentPrivacyChange",
  "comment_id": 453,
  "public": false
}
```

#### Ticket Create Events
Each property that is set on a newly created Ticket is tracked with a Create event.

Create events have the following keys:

| Name       | Type            | Read-only | Comment
| ---------- | --------------- | --------- | -------
| id         | integer         | yes       | Automatically assigned when creating events
| type       | string          | yes       | Has the value `Create`
| field_name | string          | yes       | The name of the field that was set
| value      | string / array  | yes       | The value of the field that was set

`value` will always be a string, except when when the `field_name` is `tags`

#### Example
```js
{
  "id":         1274,
  "type":       "Create"
  "field_name": "status",
  "value":      "new"
}
```

#### Ticket Change Events
When a ticket is updated, Change events track the previous and newly updated value of each ticket property.

Change events have the following keys:

| Name           | Type            | Read-only | Comment
| -------------- | --------------- | --------- | -------
| id             | integer         | yes       | Automatically assigned when creating events
| type           | string          | yes       | Has the value `Change`
| field_name     | string          | yes       | The name of the field that was changed
| value          | string / array  | yes       | The value of the field that was changed
| previous_value | string / array  | yes       | The previous value of the field that was changed

`value` and `previous_value` will always be strings, except when when the `field_name` is `tags`

#### Example
```js
{
  "id":            1274,
  "type":          "Change"
  "field_name":    "subject",
  "value":         "My printer is on fire!",
  "previous_value": "I need help!"
}
```

#### Notifications
When a Ticket is created or updated, business rules are evaluated against the Ticket.  These business rules can be configured to send various notifications.

Notifications have the following keys:

| Name            | Type                   | Read-only | Comment
| --------------- | ---------------------- | --------- | -------
| id              | integer                | yes       | Automatically assigned when creating events
| type            | string                 | yes       | Has the value `Notification`
| subject         | string                 | yes       | The subject of the message sent to the recipients
| body            | string                 | yes       | The message sent to the recipients
| recipients      | array                  | yes       | A array of simple object holding the ids and names of the recipients of this notification
| via             | [Via](#the-via-object) | yes       | A reference to the trigger that created this notification

#### Example
```js
{
  "id":         1275,
  "type":       "Notification"
  "subject":    "Your ticket has been updated"
  "body":       "Ticket #235 has been updated"
  "recipients": [847390, 93905],
  "via": {
    "channel": "system",
    "source": {
      "type":  "rule",
      "id":    61,
      "title": "Notify assignee of comment update"
    }
  }
}
```

#### Ticket CC Events
When a CC (also known as a Collaborator) is notified of a Ticket update, a CC event is added.

Ticket CC Events have the following keys:

| Name            | Type                   | Read-only | Comment
| --------------- | ---------------------- | --------- | -------
| id              | integer                | yes       | Automatically assigned when creating events
| type            | string                 | yes       | Has the value `Cc`
| recipients      | array                  | yes       | A array of simple object holding the ids and names of the recipients of this notification
| via             | [Via](#the-via-object) | yes       | A reference to the trigger that created this notification

#### Example
```js
{
  "id":         1275,
  "type":       "Cc"
  "recipients": [847390, 93905],
  "via": {
    "channel": "system",
    "source": {
      "type":  "rule",
      "id":    61,
      "title": "Notify assignee of comment update"
    }
  }
}
```

#### Ticket Errors

Ticket Error events track any system errors that occur in the processing of a ticket.

Ticket errors have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `Error`
| message         | string  | yes       | The error message

#### Example
```js
{
  "id":      1274,
  "type":    "Error",
  "message": 453
}
```

#### External Ticket Events

External ticket events have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `External`
| resource        | string  | yes       | TODO
| body            | string  | yes       | TODO
| success         | string  | yes       | TODO

#### Example
```js
{
  "id":       1274,
  "type":     "External",
  "resource": "WE NEED A GOOD EXAMPLE", //TODO
  "body":     "WE NEED A GOOD EXAMPLE", //TODO
  "success":  "WE NEED A GOOD EXAMPLE" //TODO
}
```

#### Facebook Events
Facebook Events track when a Facebook comment was posted back to a Facebook Wall post or Facebook Page private message.

Facebook Events have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `FacebookEvent`
| page            | hash    | yes       | The name and graph id of the Facebook Page associated with the event
| communication   | integer | yes       | The Zendesk id of the associated communication (wall post or message)
| ticket_via      | string  | yes       | "post" or "message" depending on association with a Wall Post or a Private Message
| body            | string  | yes       | The value of the message posted to Facebook

#### Example
```js
{
  "id":   1274,
  "type": "FacebookEvent",
  "page": {
    "name" => "Zendesk",
    "graph_id" => "61675732935"
  },
  "communication" => 5,
  "ticket_via" => "post"
  "body" => "Thanks!"
}
```

#### Log Me In Transcript Events
Log Me In Transcript events have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `LogMeInTranscript`
| body            | string  | yes       | TODO

#### Example
```js
{
  "id":   1274,
  "type": "LogMeInTranscript",
  "body": "WE NEED A GOOD EXAMPLE" //TODO
}
```

#### Push Events
Push events have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `Push`
| value           | string  | yes       | TODO
| value_reference | string  | yes       | TODO

#### Example
```js
{
  "id":              1274,
  "type":            "Push",
  "value":           "WE NEED A GOOD EXAMPLE", //TODO
  "value_reference": "WE NEED A GOOD EXAMPLE" //TODO
}
```

#### Satisfaction Rating Events
Satisfaction rating events have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `SatisfactionRating`
| score           | string  | yes       | The rating state "offered", "unoffered", "good", "bad"
| assignee_id     | integer | yes       | Who the ticket was assigned to upon rating time
| body            | string  | yes       | The users comment posted during rating

#### Example
```js
{
  "id":          1274,
  "type":        "SatisfactionRating",
  "score":       "good",
  "assignee_id": 87374,
  "body":        "Thanks, you guys are great!"
}
```

#### Tweet Events
Tweet events have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `Tweet`
| direct_message  | boolean | yes       | Whether this tweet was a direct message
| body            | string  | yes       | The body of the tweet
| recipients      | array   | yes       | The recipients of this tweet

#### Example
```js
{
  "id":             1274,
  "type":           "Tweet",
  "direct_message": false,
  "body":           "Hi there",
  "recipients":     [847390, 93905]
}
```

#### SMS Events
SMS events have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `SMS`
| body            | string  | yes       | TODO
| phone_number    | string  | yes       | TODO
| recipient_id    | string  | yes       | TODO

#### Example
```js
{
  "id":           1274,
  "type":         "SMS",
  "body":         "There is an update on Zendesk Ticket #5656",
  "phone_number": "555 123 4567",
  "recipient_id": 9873938
}
```

#### Ticket Sharing Events
Ticket sharing events have the following keys:

| Name            | Type    | Read-only | Comment
| --------------- | ------- | --------- | -------
| id              | integer | yes       | Automatically assigned when creating events
| type            | string  | yes       | Has the value `TicketSharingEvent`
| agreement_id    | integer | yes       | TODO
| action          | string  | yes       | either `shared` or `unshared` TODO

#### Example
```js
{
  "id":           1274,
  "type":         "TicketSharingEvent",
  "agreement_id": 3454,
  "action":       "shared"
}
```
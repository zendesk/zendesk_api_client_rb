## Account Settings

### JSON Format
Account Settings are read-only. They contain settings for the various aspects of an Account.

### Branding

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| header_color                       | string  | HEX of the header color
| page_background_color              | string  | HEX of the page background color
| tab_background_color               | string  | HEX of tab background color
| text_color                         | string  | HEX of the text color, usually matched to contrast well with `header_color`

### Apps

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| use                                | boolean | The Account can use apps
| create_private                     | boolean | The Account can create private apps
| create_public                      | boolean | The Account can create public apps

### Tickets

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| comments_public_by_default         | boolean | Comments from agents are public by default
| list_newest_comments_first         | boolean | When viewing a ticket, show the newest comments and events first
| collaboration                      | boolean | CCs may be added to a ticket
| private_attachments                | boolean | Users must login to acesss attachments
| agent_collision                    | boolean | Clients should provide an indicator when a ticket is being viewed by another agent
| list_empty_views                   | boolean | Clients should display Views with no matching Tickets in menus
| maximum_personal_views_to_list     | number  | Maximum number of personal Views clients should display in menus
| tagging                            | boolean | Tickets may be tagged
| markdown_ticket_comments           | boolean | Whether agent comments should be processed with Markdown

### Chat

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| enabled                            | boolean | Chat is enabled
| maximum_requests                   | number  | The maximum number of chat requests an agent may handle at one time
| welcome_message                    | string  | The message automatically sent to end-users when they begin chatting with an agent

### Twitter

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| shorten_url                        | string | Possible values: 'always', 'optional', 'never'

### Voice

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| enabled                            | boolean | Voice is enabled
| maintenance                        | boolean |
| logging                            | boolean |

### Users

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| tagging                            | boolean | Users may be tagged

### Screencast

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| enabled_for_tickets                | boolean | Account can record Screencasts on Tickets.
| host                               | string  | The Screenr domain used when recording and playing Screencasts.
| tickets_recorder_id                | string  | The Screenr Recorder id used when recording Screencasts.

### GooddataAdvancedAnalytics

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| enabled                            | boolean | GoodData Advanced Analytics is enabled

### Billing

| Name                               | Type    | Comment
| ---------------------------------- | ------- | -------
| backend                            | string  | Backend Billing system either 'internal' or 'zuora'

#### Example

```js
"settings": {
  "branding": {
    "header_color": "1A00C3",
    "page_background_color": "333333",
    "tab_background_color": "3915A2",
    "text_color": "FFFFFF"
  },
  "apps":{
    "use":            true,
    "create_private": false,
    "create_public":  true
  },
  "tickets": {
    "comments_public_by_default":     true,
    "list_newest_comments_first":     true,
    "collaboration":                  true,
    "private_attachments":            true,
    "agent_collision":                true
    "list_empty_views":               true,
    "maximum_personal_views_to_list": 12,
    "tagging":                        true,
    "markdown_ticket_comments":       false
  },
  "chat": {
    "maximum_request_count": 5,
    "welcome_message":       "Hello, how may I help you?",
    "enabled":               true
  },
  "voice": {
    "enabled":     true,
    "maintenance": false,
    "logging":     true
  },
  "twitter": {
    "shorten_url":"optional"
  },
  "users": {
    "tagging":true
  }
  "billing" :{
     "backend": 'internal'
   }
}
```

### Show Settings
`GET /api/v2/account/settings.json`

This shows the settings that are available for the account.

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/account/settings.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

"settings": {
  "apps": {.. },
  "tickets": { ...  },
  "chat": { ... },
  "twitter": { ... },
  "users": { ... }
}
```

### Update Account Settings
`PUT /api/v2/account/settings.json`

#### Allowed For

 * Admins

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/account/settings.json \
  -H "Content-Type: application/json" -X PUT \
  -d '{ "settings": { "lotus": { "prefer_lotus": false }}}' \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

"settings": {
  "apps": {.. },
  "tickets": { ...  },
  "chat": { ... },
  "twitter": { ... },
  "users": { ... }
}
```
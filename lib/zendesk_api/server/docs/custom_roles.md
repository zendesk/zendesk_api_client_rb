## Custom Agent Roles

Zendesk enterprise accounts have the option of providing a more granular access to their agents. This is done using custom roles, which is a specialization of the agent role. This API provides access to list the specialized roles available on the account.

### List Custom Roles
`GET /api/v2/custom_roles.json`

#### Availability

 * Accounts on the enterprise plan

#### Allowed For:

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/custom_roles.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "custom_roles": [
    {
      "id":             16,
      "name":           "Advisor",
      "description":    "Advisors manage the workflow and configure the help desk. They create or manage automations, macros, triggers, views, and SLA targets. They also set up channels and extensions. Advisors don't solve tickets, they can only make private comments.",
      "created_at":     "2012-03-12T16:32:22Z",
      "updated_at":     "2012-03-12T16:32:22Z",
      "configuration": {
        "chat_access":                     true,
        "end_user_profile":                "readonly",
        "forum_access":                    "readonly",
        "forum_access_restricted_content": false,
        "macro_access":                    "full",
        "manage_business_rules":           true,
        "manage_dynamic_content":          false,
        "manage_extensions_and_channels":  true,
        "manage_facebook":                 false,
        "organization_editing":            false,
        "report_access":                   "none",
        "ticket_access":                   "within-groups",
        "ticket_comment_access":           "private",
        "ticket_deletion":                 false,
        "ticket_editing":                  true,
        "ticket_merge":                    false,
        "ticket_tag_editing":              true,
        "twitter_search_access":           true,
        "view_access":                     "full"
      },
    },
    {
      "id":             6,
      "name":           "Staff",
      "description":    "A Staff agent's primary role is to solve tickets. They can edit tickets within their groups, view reports, and add or edit personal views and macros.",
      "created_at":     "2011-07-20T04:31:29Z",
      "updated_at":     "2012-02-02T10:32:59Z",
      "configuration": {
        "chat_access":                     true,
        "end_user_profile":                "readonly",
        "forum_access":                    "readonly",
        "forum_access_restricted_content": false,
        "macro_access":                    "full",
        "manage_business_rules":           true,
        "manage_dynamic_content":          false,
        "manage_extensions_and_channels":  true,
        "manage_facebook":                 false,
        "organization_editing":            false,
        "report_access":                   "none",
        "ticket_access":                   "within-groups",
        "ticket_comment_access":           "private",
        "ticket_deletion":                 false,
        "ticket_editing":                  true,
        "ticket_merge":                    false,
        "ticket_tag_editing":              true,
        "twitter_search_access":           true,
        "view_access":                     "full"
      },
    }
  ]
}
```

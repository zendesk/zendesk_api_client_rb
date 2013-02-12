## Changes Roadmap

As part of our [change policy](introduction.html#change-policy), we provide this roadmap of API changes to help developers plan for required changes to their integrations with Zendesk. Please also subscribe to our [API updates forum](https://support.zendesk.com/forums/20635666-api-changes) for announcements and changes to this roadmap.

### December 6, 2012

The following changes will go into effect on December 6, 2012:

#### Proper handling of requester and submitter for Ticket creation

##### Affected endpoints

``POST /api/v2/tickets.json``

##### What's changing

Our API is commonly used to create ticket submission forms on company websites. However, companies want to be able to set internally-facing fields on the ticket (such as tags), which requires agent authentication, while making the ticket appear as created by the customer. Today, any ticket created via the API inaccurately shows "via (Agent Name)" on the ticket UI.

This will change to only allow two valid states for a ticket's first comment author:

* Created by the requester, where the first comment author is the requester.
* Created by the requester via an agent, where the first comment author is an agent.

##### Example

The below will create a ticket where the requester is the first comment author:

```
{
  "ticket": {
    "comment": {
      "value": "This is the ticket description"
    },
    "requester": {
      "name": "Customer",
      "email": "customer@domain.com"
    }
  }
}
```

The below will create a ticket where the agent designated as the submitter is the first comment author, and the ticket is shown as created by the requester, via the agent.

```
{
  "ticket": {
    "comment": {
      "value": "This is the ticket description"
    },
    "requester": {
      "name": "Customer",
      "email": "customer@domain.com"
    },
    "submitter_id": 7
  }
}
```


### February 7, 2013

The following changes will go into effect on February 7, 2013:

#### Removal of ``fields`` key in favor of ``custom_fields`` for Tickets, Requests and Macros

##### Affected endpoints

* ``GET /api/v2/tickets/{id}.json``
* ``GET /api/v2/requests/{id}.json``
* ``GET /api/v2/macros/{id}/apply.json``

##### Deprecation

On November 8, 2012, in the above endpoints, ``custom_fields`` were added and ``fields`` were deprecated.

##### What's changing

To improve naming consistencies in our API, we are renaming ``fields`` to ``custom_fields`` in the above endpoints.

##### Example

```
{
  "ticket": {
    "id": 123,
    "fields": [
      {
        "id": 456,
        "value": "value_1"
      },
      {
        "id":457,
        "value": "value_2"
      }
    ]
  }
}
```

will be changed to

```
{
  "ticket": {
    "id": 123,
    "custom_fields": [
      {
        "id": 456,
        "value": "value_1"
      },
      {
        "id":457,
        "value": "value_2"
      }
    ]
  }
}
```

#### Removal of ``fields``, ``custom_fields``, ``group_by``, ``group_order``, ``sort_order``, ``sort_by`` in favor of ``columns``, ``group`` and ``sort`` for Views

##### Affected endpoints

* ``GET /api/v2/views/{id}.json``

##### Deprecation

On November 13, 2012, in the above endpoint, ``columns``, ``group`` and ``sort`` were added and ``fields``, ``custom_fields``, ``group_by``, ``group_order``, ``sort_order``, ``sort_by`` were deprecated.

##### What's changing

To improve usability of this API, with respect to rendering view columns, we now expose a ``columns`` attribute in Views which expresses the order, header title and ID of each column in the View which corresponds to data presented in each row of the View.

Furthermore, we have consolidated the grouping and sorting definitions of each View into the ``group`` and ``sort`` attributes.

##### Example

```
{
  "view": {
    "id": 2568,
    "title": My working tickets",
    ...
    "execution": {
      "group_by": "status",
      "group_order": "asc",
      "sort_by": "updated",
      "sort_order": "desc",
      "fields": [
        {
          "id": "nice_id",
          "title": "ID"
        },
        {
          "id": "type",
          "title": "Type"
        }
        ...
      ],
      "custom_fields": [
        {
          "id": 336767,
          "title": "About"
        }
      ]
    }
    ...
  }
}
```

will be changed to

```
{
  "view": {
    "id": 2568,
    "title": My working tickets",
    ...
    "execution": {
      "group": {
        "id": "status",
        "title": "Status",
        "order": "asc"
      },
      "sort": {
        "id": "updated",
        "title": "Updated",
        "order": "desc"
      },
      "columns": [
        {
          "id": "id",
          "title": "ID"
        },
        {
          "id": "type",
          "title": "Type"
        },
        {
          "id": 336767,
          "title": "About",
          "type": "tagger"
        }
        ...
      ],
    }
    ...
  }
}
```

### April 24, 2013

The following changes will go into effect on April 24, 2013:

#### Moving miscellaneous side-loads into the resource itself

##### Affected endpoints

* ``GET /api/v2/tickets.json``
* ``GET /api/v2/tickets/{id}.json``
* ``GET /api/v2/organizations.json``
* ``GET /api/v2/organizations/{id}.json``
* ``GET /api/v2/users.json``
* ``GET /api/v2/users/{id}.json``

##### Deprecation

On January 28, 2012, in the above endpoints, the following side-loaded resources were added
to the actual model and the root-level side-load was deprecated.

Tickets: last_audits, metric_sets
Organizations: abilities
Users: abilities

##### What's changing

To improve consistencies in our API, we are moving some side-loads that are unbounded and never
duplicated into the actual model instead of at the root level.

##### Example

```
GET /api/v2/users.json?include=abilities

{
  "users": [{
    "id": 1,
    ...
  },
  {
    "id": 2,
    ...
  }],
  "abilities": [{
    "user_id": 1,
    ...
  },
  {
    "user_id": 2,
    ...
  }]
}
```

will now return

```
{
  "users": [{
    "id": 1,
    "abilities": {
      "user_id": 1,
      ...
    }
  },
  {
    "id": 2,
    "abilities": {
      "user_id": 2,
      ...
    }
  }]
}
```
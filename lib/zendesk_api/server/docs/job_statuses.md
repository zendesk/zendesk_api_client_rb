## Job Statuses

### JSON Format
Job statuses have the below attributes

| Name            | Type                             | Read-only | Mandatory | Comment
| --------------- | ---------------------------------| --------- | --------- | -------
| id              | string                           | yes       | no        | Automatically assigned as job gets enqueued
| url             | string                           | yes       | no        | The URL to poll for status updates
| total           | integer                          | yes       | no        | The total number of tasks this job is batching through
| progress        | integer                          | yes       | no        | Number of tasks that have already been completed
| status          | string                           | yes       | no        | The current status, "working", "failed", "completed", "killed"
| message         | string                           | yes       | no        | Message from the job worker, if any
| results         | array                            | yes       | no        | Result data from processed tasks

#### Example
```js
{
  "id":         "8b726e606741012ffc2d782bcb7848fe",
  "url":        "https://company.zendesk.com/api/v2/job_statuses/8b726e606741012ffc2d782bcb7848fe.json",
  "total":      2,
  "progress":   2,
  "status":     "completed",
  "message":    "Completed at Fri Apr 13 02:51:53 +0000 2012",
  "results": [
    {
      "title":   "I accidentally the whole bottle",
      "action":  "update",
      "errors":  "",
      "id":      380,
      "success": true,
      "status":  "Updated"
    },
    {
      "title":   "Printer on fire",
      "action":  "update",
      "errors":  "",
      "id":      90,
      "success": true,
      "status":  "Updated"
    }
  ]
}
```

### Show Job Status
`GET /api/v2/job_statuses/{id}.json`

This shows the status of a background job.

#### Allowed For:

 * Anyone

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/job_statuses/{id}.json \
  -v -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "id":         "8b726e606741012ffc2d782bcb7848fe",
  "url":        "https://company.zendesk.com/api/v2/job_statuses/8b726e606741012ffc2d782bcb7848fe.json",
  "total":      2,
  "progress":   2,
  "status":     "completed",
  "message":    "Completed at Fri Apr 13 02:51:53 +0000 2012",
  "results": [
    {
      "title":   "I accidentally the whole bottle",
      "action":  "update",
      "errors":  "",
      "id":      380,
      "success": true,
      "status":  "Updated"
    },
    ...
 ]
}
```
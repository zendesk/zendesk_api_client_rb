## Attachments

### JSON Format
Attachments are represented as JSON objects with the following keys:

| Name         | Type             | Read-only | Comment
| ------------ | ---------------- | --------- | -------
| id           | integer          | yes       | Automatically assigned when created
| file_name    | string           | yes       | The name of the image file
| content_url  | string           | yes       | A full URL where the attachment image file can be downloaded
| content_type | string           | yes       | The content type of the image. Example value: `image/png`
| size         | integer          | yes       | The size of the image file in bytes
| thumbnails   | array            | yes       | An array of [Photo](#attachments) objects. Note that thumbnails do not have thumbnails.

#### Example
```js
{
  "id":           928374,
  "file_name":    "my_funny_profile_pic.png",
  "content_url":  "https://company.zendesk.com/attachments/my_funny_profile_pic.png",
  "content_type": "image/png",
  "size":         166144,
  "thumbnails": [
    {
      "id":           928375,
      "file_name":    "my_funny_profile_pic_thumb.png",
      "content_url":  "https://company.zendesk.com/attachments/my_funny_profile_pic_thumb.png",
      "content_type": "image/png",
      "size":         58298
    }
  ]
}
```

### Uploading files
`POST /api/v2/uploads.json`

Adding multiple attachments to the same upload is handled by splitting requests and
passing the token received from the first request to each subsequent one.

#### Allowed For

 * End Users

#### Using curl

```bash
 curl -u username:password -H "Content-Type: application/binary" \
   --data-binary @file.dat -X POST \
   "https://helpdesk.zendesk.com/api/v2/uploads.json?filename=myfile.dat&token={optional_token}"
```

#### Example Response

```http
Status: 201 Created

{
  "upload": {
    "token": "6bk3gql82em5nmf",
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
}
```

### Deleting Uploads
`DELETE /api/v2/uploads/{token}.json`

#### Allowed For

 * Agents

#### Using curl

```bash
 curl -u username:password -X DELETE https://helpdesk.zendesk.com/api/v2/uploads/{token}.json
```

#### Example Response

```http
200 OK
```

### Getting Attachments
`GET /api/v2/attachments/{id}.json`

#### Allowed For

 * Admins

#### Using curl

```bash
 curl -u username:password https://helpdesk.zendesk.com/api/v2/attachments/{id}.json
```

#### Example Response

```http
{
  "attachment": {
    "id":           498483,
    "name":         "crash.log",
    "content_url":  "https://company.zendesk.com/attachments/crash.log",
    "content_type": "text/plain",
    "size":         2532,
    "thumbnails":   [],
    "url":          "https://company.zendesk.com/api/v2/attachments/498483.json",
  }
}
```

### Deleting Attachments
`DELETE /api/v2/attachments/{id}.json`

Currently, only attachments on forum posts are allowed to be deleted.

#### Allowed For

 * Admins

#### Using curl

```bash
 curl -u username:password -X DELETE https://helpdesk.zendesk.com/api/v2/attachments/{id}.json
```

#### Example Response

```http
200 OK
```
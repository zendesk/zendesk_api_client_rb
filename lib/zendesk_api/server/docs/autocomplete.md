## Autocompletion

### Autocomplete Tags
`POST /api/v2/autocomplete/tags.json?name={name}`

Returns an array of registered and recent tag names that start with the specified name.
The name must be at least 2 characters in length.

#### Allowed For

 * Agents

#### Using curl

```bash
curl https://{subdomain}.zendesk.com/api/v2/autocomplete/tags.json \
  -X POST -d '{"name": "att"}' -H "Accept: application/json" \
  -u {email_address}:{password}
```

#### Example Response

```http
Status: 200 OK

{
  "tags": [ "attention", "attack" ]
}
```
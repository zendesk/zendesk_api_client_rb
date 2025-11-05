If you are a Zendesk engineer, you can find the currently used test account in Pandora by “zendesk_api_client” tag (or pool).

In case you want to create a test account from scratch:
 - Create an empty account (again, use Pandora if you are a Zendesk engineer). Set company name to Z3N.
 - Create a second Admin user (don’t use the owner account in tests: owners cannot verify user identities). Ensure this new user has an organization. Then, add the new user credentials to `spec/fixtures/credentials.yml`
 - Activate Help Center
 - Enable “Allow customers to rate tickets” in People → Configuration → End users → Satisfaction 
 - Mark 1 ticket as solved, change end-users email to one you can receive, copy ticket url, login as end-user (do not just assume identity), rate it. You might need to check that request page layout includes Satisfaction (in Theming Center). Alternatively, receive an email from the “Request customer satisfaction rating” automation (change its parameters to send notifications earlier than in 24 hours)
 - Create a user field in Admin Center → People → Configuration → User fields
 - In `article_spec.rb`, replace `permission_group_id`. Use `curl` to list permission groups for this account: `curl https://{subdomain}.zendesk.com/api/v2/guide/permission_groups.json -u {email_address}:{password}`.
 - After running `article_spec.rb` once, log in as an end user (it can be the same as above) and upvote the “What are these sections and articles doing here?” article.
 - Add photo to user profile of that end user.
 - Create a new ticket and cc "zendesk-api-client-ruby-end-user-#{client.config.username}" (run tests once to create this user)
 - Ensure you allow admins to set up user password (or `POST /api/v2/users/{user_id}/password.json` will fail). You can check this in the admin centre > security > advanced

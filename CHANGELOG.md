# CHANGELOG

## Unreleased

## v3.0.0.rc1

In this version, We are bringing Cursor Based Pagination (CBP) support to all supported endpoints. This is in line with the [limits announcement](https://support.zendesk.com/hc/en-us/articles/5591904358938-New-limits-for-offset-based-pagination) made by Zendesk to promote system reliability and also CBP usage.

- `Collection#all` uses CBP by default instead of Offset Based Pagination (OBP). If an endpoint doesn't support CBP, then a new OBP request will be triggered automatically with the same parameters. This is managed by the library internally
- `Collection#next and #prev` using CBP by default
- The pagination behaviour of search and export endpoint have not changed
- We are adding support for [httpx](https://rubygems.org/gems/httpx). We will be monitoring the issues and feedback to determine if we continue the support and make it into a stable release

**Notes:**

- OBP support will be further limited in the Zendesk APIs and will be deprecated soon. We are working to ensure all Zendesk APIs support CBP and transition for the customers is smooth
- The order of the returned results is different in CBP from OBP at times depending on the endpoint behaviour and support for ordering. Please note that any ordering was never hard-coded or built-in so it is not guaranteed. We recommend that you pick the relevant sort/order needed for your workflows and pass them explicitly when making the API call via the library
- This is a Beta-release and we seek your feedback, experiences. Please open an issue or create a PR to help us work with you

## v2.0.1

- More complete error message for `RecordInvalid`

## v2.0.0 (BREAKING!)

- Add support for Faraday 2.0
- Add `Label` resource for Articles
- Add Ruby 3.2 to CI
- Add JRuby 9.4 to CI
- Drop support for Faraday 1
- Remove 2.6 from CI
- Remove JRuby 9.1 from CI, see https://github.com/zendesk/zendesk_api_client_rb/runs/8110095881
- Remove JRuby 9.2 from CI, see https://github.com/zendesk/zendesk_api_client_rb/runs/8110151024

**Note:**

It is possible that the SDK will work okay in Ruby 2.6, but we do not guarantee it, and also support will not be provided on any issues.

We will continue to support Ruby 2.7 owing to the large set of developers still on Ruby 2. The support will end by Jan 2024.

We strongly recommend everyone to consider moving to Ruby 3 at the earliest.

## v1.37.0

- Fix Faraday v1 deprecation

## v1.36.0

- Fix: Ticket comments should be sent unchanged
- Update README: Document the [REPL project](https://github.com/zendesk/zendesk_api_client_rb_repl), add release instructions
- Add `Schedule` resource
- Add `Vote` resource for Articles
- Add `CustomStatus` resource
- Add `Translation` resource for Categories, Sections, and Articles

## v1.35.0

- Abandoned support for Ruby 2.5 (EOL)
- Tested in Ruby 3.1
- Add `Webhook` resource
- Add `Organization#create_or_update`
- Bug-fixing
- Improved documentation

## v1.34.0

- Refine https check for URL
- Support installations with hashie 5.0.0
- Add `OrganizationMembership.create_or_update{,!}`

## v1.33.0

- Expand retry logic to support retries on 5xx error codes

## v1.32.0

- Add more info to ZendeskAPI::Error::RecordInvalid

## v1.31.0

- Upgrade addressable dependency

## v1.30.0

- Add configuration option to disable resource cache
- Add RecipientAddress resource
- Upgrade VCR and actionpack testing dependencies

## v1.29.0

- Add Organization Related resource
- Add Deleted Users and Deleted Tickets resource
- Switch over mini_mime for mime type lookups

## v1.28.0

- Add Trigger categories resource

## v1.27.0

- Add Section and Article resources

## v1.26.0

- Allow using hashie 4.x
- Add support to merge user API

## v1.25.0

- Allow using Faraday 1.x release in gemspec

## v1.24.0

- Added support for `UserRelated` operation on users resource
- Bring back `UpdateMany` on users resource

## v1.23.0

- Fix Faraday deprecation notice and relax required version

## v1.22.0

- Fix `CreateOrUpdate` action to use singular resource name
- Add `CreateMany`, `CreateOrUpdate` and `DestroyMany` to Organizations

## v1.21.0

- Add support for `.find` attachments
- Set default request timeout of 60 seconds
- Add gem project metadata
- Add meaningful error when the username is not set using basic token auth

## v1.20.0

- Bring back spec live testing

## v1.19.1

- Remove forums resource and start using community topics
- Add assigned tickets association

## v1.19.0

- Add option to raise error when rate limited

## v1.18.0

- Add support for create_or_update for user resource
- Update ticket incremental export endpoint
- Add support to create or update many users and remove unsupported update many users
- Define respond_to_missing?

## v1.17.0

dropped support for Ruby 1.9.x, 2.0.x, 2.1.x and 2.2.x, all of which are EOL

## v1.16.0

log response body for 4xx errors (https://github.com/zendesk/zendesk_api_client_rb/pull/354)

## v1.15.0

support batch update resources (https://github.com/zendesk/zendesk_api_client_rb/pull/344)

## v1.14.4

document hashie dependency

## v1.14.3

silence logging spam (https://github.com/zendesk/zendesk_api_client_rb/pull/327)

## v1.14.2

make error also work without an response

silence rubocop and show which offense was triggered

make extra output obvious by using default formatter

silence invalid file warning

silence logger

silence mashie

```
You are setting a key that conflicts with a built-in method Hashie::Mash#class defined in Kernel. This can cause unexpected behavior when accessing the key via as a property. You can still access the key via the #[] method.
```

## v1.14.1

avoid double builds

show what exactly went wrong

Remove dependency on scrub_rb

For people using Ruby 2.1 or newer, this gem is dead weight. Let's just document
that if you use an old version of Ruby, you need to install a gem that
implements `scrub!` for you.

Fix addressable on older Rubies

## v1.14.0

added live spec

json v > 2.0 fails to install for ruby 1.9

Moved dev dependencies to Gemfile

added OrganizationSubscription

Support for unified Integer class in Ruby 2.4+

Ruby 2.4 unifies Fixnum and Bignum into Integer: https://bugs.ruby-lang.org/issues/12005

Enable a few more cops

Configure and enable a few indentation cops

Enable a few style cops

Enable RuboCop check after running specs

Remove version constraint on mime-types

Clients using Ruby < 2.0 should themselves set a version restriction so they
don't install mime-types >= v3.0.

Lock webmock version to get green build

## v1.13.4

fix some rubocop warnings

fix deprecation warning on ruby 2.3.0

## v1.13.3

Add agent Set Group Membership as Default

https://developer.zendesk.com/rest_api/docs/core/group_memberships#set-m
embership-as-default

## v1.13.2

fix method_as_class to handle non alphanumeric

remove extra line

gemspec cleanup

Don't need to send spec/ files along. Saves ~120kb.

remove ruby 1.8 from the gemfile

lock mime-types for ruby 1.9

mime-types 3.0 only supports ruby 2.0

only show bang! methods in README

DELETEs return 204s now

## v1.13.1

add a gzip middleware exception for httpclient

## v1.12.1

add user \*\_many endpoints

fix doc gitignores

add some more documentation

fix namespace walking in yardoc plugin [ci skip]

fix markdown generation [ci skip]

update class documentation link

fix documentation [ci skip]

## v1.12.0

restoring gemspec to the previous required ruby version

Sanitizing body responses to deal with bad characters.

## v1.11.7

Revert "always upload files as inline"

This reverts commit cc97c3733e47f524595b9dc35068218e7a410acd.

## v1.11.6

## v1.11.5

make user tags a proper association

## v1.11.4

add CreateMany and DestroyMany to Ticket

## v1.11.3

small spacing fix

## v1.11.2

always upload files as inline

Update pull request #254
Add .bundle/ to .gitignore
Rename Ticket::display to Ticket::display!

## v1.11.1

Get RecordInvalid message from description in absence of details

## v1.11.0

Add agent resource and ticket-display feature

Implement update_many!

fix documentation for incremental export

issue #250

## v1.10.0

Change User-Agent to be Ruby specific

fix apps installation spec

remove multi_json

update sample app for 1.0

change live spec for recent tickets

no longer extending Read, just include

don't save existing comment associations

silence rspec warnings

## v1.9.6

make Voice::Ticket a CreateResource

Add zendesk voice ticket resource #245

## v1.9.5

destroy_many uses a comma separated list of ids

## v1.9.4

organization memberships are not updatable

Adds Organization Membership resource

## v1.9.3

Actually use the client

## v1.9.2

fix destroy_many! and create_many! on collections

## v1.9.1

Allow bulk actions on collections

## v1.9.0

Introduce reload!

Refactored initializer

return JobStatus

Bulk actions!

## v1.8.0

update README

add tests

consider all 3XX and 1XX responses invalid except for 304

AppNotification#handle_response: only call @attributes#replace if response is a hash

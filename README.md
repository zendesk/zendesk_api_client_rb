# Zendesk API Client

[![Test](https://github.com/zendesk/zendesk_api_client_rb/workflows/Test/badge.svg)](https://github.com/zendesk/zendesk_api_client_rb/actions/workflows/main.yml?query=branch%3Amaster)
[![Gem Version](https://badge.fury.io/rb/zendesk_api.svg)](https://badge.fury.io/rb/zendesk_api)
[![Code Climate](https://codeclimate.com/github/zendesk/zendesk_api_client_rb.svg)](https://codeclimate.com/github/zendesk/zendesk_api_client_rb)

## Documentation

This Ruby gem is a generic wrapper around Zendesk's REST API. Follow this README and the [wiki](https://github.com/zendesk/zendesk_api_client_rb/wiki) for how to use it.

You can interact with all the resources defined in [`resources.rb`](lib/zendesk_api/resources.rb). Basically we have some clever code to convert Ruby objects into HTTP requests.

Please refer to our [API documentation](https://developer.zendesk.com/api-reference) for the specific endpoints and once you understand the mapping between Ruby and the HTTP endpoints you should be able to call any endpoint.

The Yard generated documentation is available in at [RubyDoc](https://www.rubydoc.info/gems/zendesk_api).

Please report any bug in the [Github issues page](https://github.com/zendesk/zendesk_api_client_rb/issues).

You might want to try out this gem in a REPL for exploring your options, if so, check out [this project](https://github.com/zendesk/zendesk_api_client_rb_repl).

## Product Support

This Ruby gem supports the REST API's for Zendesk Support, Zendesk Guide,
and Zendesk Talk. It does not yet support other Zendesk products such as
Zendesk Chat, Zendesk Explore, and Zendesk Sell.

## Installation

The Zendesk API client can be installed using Rubygems or Bundler.

### Rubygems

```sh
gem install zendesk_api
```

### Bundler

Add it to your Gemfile

```
gem "zendesk_api"
```

Then `bundle` as usual.

## Configuration

Configuration is done through a block returning an instance of `ZendeskAPI::Client`.

```ruby
require 'zendesk_api'

client = ZendeskAPI::Client.new do |config|
  # Mandatory:

  config.url = "<- your-zendesk-url ->" # e.g. https://yoursubdomain.zendesk.com/api/v2

  # Basic / Token Authentication
  config.username = "login.email@zendesk.com"

  # Choose one of the following depending on your authentication choice
  # More information on obtaining API tokens can be found here:
  # https://developer.zendesk.com/api-reference/introduction/security-and-auth/#api-token
  config.token = "your zendesk token"

  # OAuth Authentication
  # More information on obtaining OAuth access tokens can be found here:
  # https://developer.zendesk.com/api-reference/introduction/security-and-auth/#oauth-access-token
  config.access_token = "your OAuth access token"

  # Optional:

  # Retry uses middleware to notify the user
  # when hitting the rate limit, sleep automatically,
  # then retry the request.
  config.retry = true

  # Raise error when hitting the rate limit.
  # This is ignored and always set to false when `retry` is enabled.
  # Disabled by default.
  config.raise_error_when_rate_limited = false

  # Logger prints to STDERR by default, to e.g. print to stdout:
  require 'logger'
  config.logger = Logger.new(STDOUT)

  # Disable resource cache (this is enabled by default)
  config.use_resource_cache = false

  # Changes Faraday adapter
  # config.adapter = :patron

  # Merged with the default client options hash
  # config.client_options = {:ssl => {:verify => false}, :request => {:timeout => 30}}

  # When getting the error 'hostname does not match the server certificate'
  # use the API at https://yoursubdomain.zendesk.com/api/v2

  # Change retry configuration (this is disabled by default)
  config.retry_on_exception = true

  # Error codes when the request will be automatically retried. Defaults to 429, 503
  config.retry_codes = [ 429 ]
end
```

## Usage

The result of configuration is an instance of `ZendeskAPI::Client` which can then be used in two different methods.

One way to use the client is to pass it in as an argument to individual classes.

_Note_: all method calls ending in `!` will raise an exception when an error occurs, see the [wiki page](https://github.com/zendesk/zendesk_api_client_rb/wiki/Errors) for more info.

```ruby
ZendeskAPI::Ticket.new(client, :id => 1, :priority => "urgent") # doesn't actually send a request, must explicitly call #save!

ZendeskAPI::Ticket.create!(client, :subject => "Test Ticket", :comment => { :value => "This is a test" }, :submitter_id => client.current_user.id, :priority => "urgent")
ZendeskAPI::Ticket.find!(client, :id => 1)
ZendeskAPI::Ticket.destroy!(client, :id => 1)
```

You can also update ticket objects.

```ruby
ticket = ZendeskAPI::Ticket.find!(client, :id => 1)
ticket.update(:comment => { :value => "This is a test reply." })

ticket.save!
```

Another way is to use the instance methods under client.

```ruby
client.tickets.first
client.tickets.find!(:id => 1)
client.tickets.build(:subject => "Test Ticket")
client.tickets.create!(:subject => "Test Ticket", :comment => { :value => "This is a test" }, :submitter_id => client.current_user.id, :priority => "urgent")
client.tickets.destroy!(:id => 1)
```

The methods under `ZendeskAPI::Client` (such as `.tickets`) return an instance of `ZendeskAPI::Collection`, a lazy-loaded list of that resource.
Actual requests may not be sent until an explicit `ZendeskAPI::Collection#fetch!`, `ZendeskAPI::Collection#to_a!`, or an applicable methods such
as `#each`.

### Caveats

Resource updating is implemented by sending only the `changed?` attributes to the server (see `ZendeskAPI::TrackChanges`).
Unfortunately, this module only hooks into `Hash` meaning any changes to an `Array` not resulting in a new instance will not be tracked and sent.

```
zendesk_api_client_rb $ bundle console
> a = ZendeskAPI::Trackie.new(:test => []).tap(&:clear_changes)
> a.changed?(:test)
 => false
> a.test << "hello"
 => ["hello"]
> a.changed?(:test)
 => false
> a.test += %w{hi}
 => ["hello", "hi"]
> a.changed?(:test)
 => true
```

### Pagination

`ZendeskAPI::Collections` can be paginated:

```ruby
# Note that CBP (cursor based pagination) is the default and preferred way
# and has fewer limitations on deep pagination
tickets = client.tickets.per_page(3)
page1 = tickets.fetch! # GET /api/v2/tickets?page[after]={cursor}&page[size]=3
page2 = tickets.next # GET /api/v2/tickets?page[after]={cursor}&page[size]=3
# ...

# OR...
# Note that OBP (offset based pagination) can incur to various limitations
tickets = client.tickets.page(2).per_page(3)

next_page = tickets.next # => 3
tickets.fetch! # GET /api/v2/tickets?page=3&per_page=3
previous_page = tickets.prev # => 2
tickets.fetch! # GET /api/v2/tickets?page=2&per_page=3
```

Iteration over all resources and pages is handled by `Collection#all`:

```ruby
client.tickets.all! do |resource|
  # every resource, from all pages, will be yielded to this block
end
```

If given a block with two arguments, the page number is also passed in.

```ruby
client.tickets.all! do |resource, page_number|
  # all resources will be yielded along with the page number
end
```

### Cursor Based Pagination

A few endpoints related to organizations, tickets, triggers and groups will now make use of cursor based pagination by default.
It is also recommended to use CBP whenever [the Zendesk developer documentation](https://developer.zendesk.com/api-reference) says it's supported.
Pass `page[size]=number` in the parameters to attempt a CBP request, like the example below:

```ruby
client.connection.get('/api/v2/suspended_tickets', page: { size: 100 }).body
{"suspended_tickets"=>[...], "meta"=>{"has_more"=>true, "after_cursor"=>" ... ", "before_cursor"=>nil}, "links"=>{"prev"=>nil, "next"=>"..."}}
```

### Callbacks

Callbacks can be added to the `ZendeskAPI::Client` instance and will be called (with the response env) after all response middleware on a successful request.

```ruby
client.insert_callback do |env|
  puts env[:response_headers]
end
```

### Resource management

Individual resources can be created, modified, saved, and destroyed.

```ruby
ticket = client.tickets[0] # ZendeskAPI::Ticket.find(client, :id => 1)
ticket.priority = "urgent"
ticket.attributes # => { "priority" => "urgent" }
ticket.save! # Will PUT => true
ticket.destroy! # => true

ZendeskAPI::Ticket.new(client, { priority: "urgent" })
ticket.new_record? # => true
ticket.save! # Will POST
```

### Side-loading

To facilitate a smaller number of requests and easier manipulation of associated data we allow "side-loading," or inclusion, of selected resources.

For example:
A `ZendeskAPI::Ticket` is associated with `ZendeskAPI::User` through the `requester_id` field.
API requests for that ticket return a structure similar to this:

```json
"ticket": {
  "id": 1,
  "url": "http.....",
  "requester_id": 7,
  ...
}
```

Calling `ZendeskAPI::Ticket#requester` automatically fetches and loads the user referenced above (`/api/v2/users/7`).
Using side-loading, however, the user can be partially loaded in the same request as the ticket.

```ruby
tickets = client.tickets.include(:users)
# Or client.tickets(:include => :users)
# Does *NOT* make a request to the server since it is already loaded
tickets.first.requester # => #<ZendeskAPI::User id=...>

# OR

ticket = client.tickets.find!(:id => 1, :include => :users)
ticket.requester # => #<ZendeskAPI::User id=...>
```

Currently, this feature is limited to only a few resources and their associations.
They are documented on [developer.zendesk.com](https://developer.zendesk.com/rest_api/docs/support/side_loading#supported-endpoints).

#### Recommended Approach

For better control over your data and to avoid large response sizes, consider fetching related resources explicitly. This approach can help you manage data loading more precisely and can lead to optimized performance for complex applications.

```ruby
ticket = ZendeskAPI::Ticket.find(id: 1)
requester = ZendeskAPI::User.find(id: ticket.requester_id)
```

By explicitly fetching associated resources, you can ensure that your application only processes the data it needs, improving overall efficiency.

### Omnichannel

Support for the [Agent Availability API](https://developer.zendesk.com/api-reference/agent-availability/agent-availability-api/introduction/)

An agent’s availability includes their state (such as online) for each channel (such as messaging), and their unified state across channels. It also includes the work items assigned to them.

```ruby
# All agent availabilities
client.agent_availabilities.fetch

# fetch availability for one agent, their channels and work items
agent_availability = ZendeskAPI::AgentAvailability.find(client, 386390041152)
agent_availability.channels
agent_availability.channels.first.work_items

# Using the agent availability filter
ZendeskAPI::AgentAvailability.search(client, { select_channel: 'support' })
ZendeskAPI::AgentAvailability.search(client, { channel_status: 'support:online' })
```

### Search

Searching is done through the client. Returned is an instance of `ZendeskAPI::Collection`:

```ruby
client.search(:query => "my search query") # /api/v2/search.json?query=...
client.users.search(:query => "my new query")  # /api/v2/users/search.json?query=...
```

### Special case: Custom resources paths

API endpoints such as `tickets/recent` or `topics/show_many` can be accessed through chaining.
They will too return an instance of `ZendeskAPI::Collection`.

```ruby
client.tickets.recent
client.topics.show_many(:verb => :post, :ids => [1, 2, 3])
```

### Special Case: Current user

Use either of the following to obtain the current user instance:

```ruby
client.users.find!(:id => 'me')
client.current_user
```

### Special Case: Importing a ticket

Bulk importing tickets allows you to move large amounts of data into Zendesk.

```ruby
ticket = ZendeskAPI::Ticket.import(client, :subject => "Help", :comments => [{ :author_id => 19, :value => "This is a comment" }])
```

Further documentation can be found on [developer.zendesk.com](https://developer.zendesk.com/rest_api/docs/support/ticket_import)

### Attaching files

Files can be attached to ticket comments using either a path or the File class and will
be automatically uploaded and attached.

```ruby
ticket = ZendeskAPI::Ticket.new(client, :comment => { :value => "attachments" })
ticket.comment.uploads << "img.jpg"
ticket.comment.uploads << File.new("img.jpg")
ticket.save!
```

### Apps API

v1.1.0 introduces support for the Zendesk [Apps API](https://developer.zendesk.com/rest_api/docs/support/apps)

#### Creating Apps

```ruby
upload = client.apps.uploads.create!(:file => "path/to/app.zip")
client.apps.create!(:name => "test", :upload_id => upload.id)

# Or

app = ZendeskAPI::App.new(client, :name => "test")
app.upload = "path/to/app.zip"
app.save!

# Or

upload = ZendeskAPI::App::Upload.new(client, :file => "path/to/app.zip")
upload.save!

app = ZendeskAPI::App.new(client, :name => "test")
app.upload_id = upload.id
app.save!

# Or

client.apps.create!(:name => "test", :upload => "app.zip")
```

*Note: job statuses are currently not supported, so you must manually poll the job status API for app creation.*

```ruby
body = {}
until %w{failed completed}.include?(body["status"])
  response = client.connection.get(app.response.headers["Location"])
  body = response.body

  sleep(body["retry_in"])
end
```

#### Updating Apps

```ruby
upload = client.apps.uploads.create!(:file => "NewApp.zip")

# Then

client.apps.update!(:id => 123, :upload_id => upload.id)

# Or

app = ZendeskAPI::App.new(client, :id => 123)
app.upload_id = upload.id
app.save!

# Or

ZendeskAPI::App.update!(client, :id => 123, :upload_id => upload.id)
```

#### Deleting Apps

```ruby
client.apps.destroy!(:id => 123)

app = ZendeskAPI::App.new(client, :id => 123)
app.destroy!

ZendeskAPI::App.destroy!(client, :id => 123)
```

#### Installing an App

**Installation name is required**

```ruby
installation = ZendeskAPI::AppInstallation.new(client, :app_id => 123, :settings => { :name => 'Name' })
installation.save!

# or

client.apps.installations.create!(:app_id => 123, :settings => { :name => 'Name' })

# or

ZendeskAPI::AppInstallation.create!(client, :app_id => 123, :settings => { :name => 'Name' })
```

#### List Installations

```ruby
apps = client.app.installations
apps.fetch!
```

#### Update Installation

```ruby
client.app.installations.update!(:id => 123, :settings => { :title => "My New Name" })

installation = ZendeskAPI::AppInstallation.new(client, :id => 123)
installation.settings = { :title => "My New Name" }
installation.save!

ZendeskAPI::AppInstallation.update!(client, :id => 123, :settings => { :title => "My New Name" })
```

#### Delete Installation

```ruby
client.app.installations.destroy!(:id => 123)

installation = ZendeskAPI::AppInstallation.new(client, :id => 123)
installation.destroy!

ZendeskAPI::AppInstallation.destroy!(client, :id => 123)
```

## Running the gem locally

See `.github/workflows/main.yml` to understand the CI process.

```
bundle exec rake # Runs the tests
bundle exec rubocop # Runs the lint (use `--fix` for autocorrect)
```

### Releasing a new version
A new version is published to RubyGems.org every time a change to `version.rb` is pushed to the `main` branch.
In short, follow these steps:
1. Update `version.rb`,
2. merge this change into `main`,
3. post a message in Slack `#rest-api`, so advocacy are aware that we are going to release a new gem, just in case any customer complains about something related to the gem,
4. after 2 hours from the above message, you can [approve the release of the gem](https://github.com/zendesk/zendesk_api_client_rb/deployments/activity_log?environment=rubygems-publish)
5. look at [the action](https://github.com/zendesk/zendesk_api_client_rb/actions/workflows/publish.yml) for output.

To create a pre-release from a non-main branch:
1. change the version in `version.rb` to something like `1.2.0.pre.1` or `2.0.0.beta.2`,
2. push this change to your branch,
3. go to [Actions → “Publish to RubyGems.org” on GitHub](https://github.com/zendesk/zendesk_api_client_rb/actions/workflows/publish.yml),
4. click the “Run workflow” button,
5. pick your branch from a dropdown.

## Contributing

1. Fork the project.
2. Make your feature addition or bug fix.
3. **Add tests for it**. This is important so that we don't break it in a future
   version unintentionally.
4. Commit. Do not alter `Rakefile`, version, or history. (If you want to have
   your own version, that is fine, but bump version in a commit by itself that
   we can ignore when we pull.)
5. Submit a pull request.

**Note:** Live specs will likely fail for external contributors. The Zendesk devs can help with that. If you have permissions and some live specs unexpectedly fail, that might be a data error, see the REPL for that.

## Merging contributors pull requests

External contributions don't run live specs, so we need to use a workaround. Assuming a PR from `author:author/branch` to `default_branch`:

1. Create a branch in our repo `author_branch`
2. Change the destination branch of the PR to `author_branch`
3. Merge
4. Create a pr in our repo from `default_branch`
   - Make sure they know the commits still carry their name
   - [Example](https://github.com/zendesk/zendesk_api_client_rb/pull/553)

## Copyright and license

Copyright 2015-2023 Zendesk

See [LICENSE](./LICENSE).

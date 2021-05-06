# Zendesk API Client

![Test](https://github.com/zendesk/zendesk_api_client_rb/workflows/Test/badge.svg)
[![Gem Version](https://badge.fury.io/rb/zendesk_api.svg)](https://badge.fury.io/rb/zendesk_api)
[![Code Climate](https://codeclimate.com/github/zendesk/zendesk_api_client_rb.svg)](https://codeclimate.com/github/zendesk/zendesk_api_client_rb)

## Documentation

This Ruby gem is a wrapper around Zendesk's REST API. Please see our [API documentation](https://developer.zendesk.com) for more information.

Please check out the [wiki](https://github.com/zendesk/zendesk_api_client_rb/wiki), [class documentation](https://www.rubydoc.info/gems/zendesk_api/), and [issues](https://github.com/zendesk/zendesk_api_client_rb/issues) before reporting a bug or asking for help.

## Product Support

This Ruby gem supports the REST API's for Zendesk Support, Zendesk Guide,
and Zendesk Talk. It does not yet support other Zendesk products such as
Zendesk Chat, Zendesk Explore, and Zendesk Sell.

## Important Notices

* Version 0.0.5 brings with it a change to the top-level namespace. All references to `Zendesk` should now use `ZendeskAPI`.
* Version 0.3.0 changed the license from MIT to Apache Version 2.
* Version 0.3.2 introduced a regression when side-loading roles on users. This was fixed in 0.3.4.
* Version 1.0.0 changes the way errors are handled. Please see the [wiki page](https://github.com/zendesk/zendesk_api_client_rb/wiki/Errors) for more info.
* Version 1.3.0 updates the Faraday dependency to 0.9. Since Faraday did not bump a major version we have not either, but there is no guarantee >= 1.3.0 works with Faraday < 0.9
* Version 1.3.8 had a bug where attachments were created, but the response was not handled properly
* Version >= 1.0 and < 1.4.2 had a bug where non application/json response bodies were discarded
* Version 1.5.0 removed support for Ruby 1.8
* Version 1.6.0 ZendeskAPI::Voice::CertificationAddress is now ZendeskAPI::Voice::Address
* Version 1.8.0 no longer considers 1XX and 3XX (except 304) response status codes valid and will raise a NetworkError
* Version 1.x.x requires you to install `scrub_rb` or `string-scrub` or similar implementation of `String#scrub!` if you're using Ruby 1.9 or 2.0.

## Installation

The Zendesk API client can be installed using Rubygems or Bundler.

### Rubygems

```sh
gem install zendesk_api
```

### Bundler

Add it to your Gemfile

    gem "zendesk_api"

and follow normal [Bundler](https://bundler.io/) installation and execution procedures.

## Configuration

Configuration is done through a block returning an instance of `ZendeskAPI::Client`.
The block is mandatory and if not passed, an `ArgumentError` will be thrown.

```ruby
require 'zendesk_api'

client = ZendeskAPI::Client.new do |config|
  # Mandatory:

  config.url = "<- your-zendesk-url ->" # e.g. https://yoursubdomain.zendesk.com/api/v2

  # Basic / Token Authentication
  config.username = "login.email@zendesk.com"

  # Choose one of the following depending on your authentication choice
  config.token = "your zendesk token"
  config.password = "your zendesk password"

  # OAuth Authentication
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

  # Changes Faraday adapter
  # config.adapter = :patron

  # Merged with the default client options hash
  # config.client_options = {:ssl => {:verify => false}, :request => {:timeout => 30}}

  # When getting the error 'hostname does not match the server certificate'
  # use the API at https://yoursubdomain.zendesk.com/api/v2
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

ZendeskAPI::Ticket.new(client, { :priority => "urgent" })
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
```

OR

```ruby
ticket = client.tickets.find!(:id => 1, :include => :users)
ticket.requester # => #<ZendeskAPI::User id=...>
```

Currently, this feature is limited to only a few resources and their associations.
They are documented on [developer.zendesk.com](https://developer.zendesk.com/rest_api/docs/support/side_loading#supported-endpoints).

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

## Note on Patches/Pull Requests
1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so that we don't break it in a future
   version unintentionally.
4. Commit. Do not alter `Rakefile`, version, or history. (If you want to have
   your own version, that is fine, but bump version in a commit by itself that
   we can ignore when we pull.)
5. Submit a pull request.

## Copyright and license

Copyright 2015-2021 Zendesk

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

# Zendesk API Client

## API version support

This client **only** supports Zendesk's v2 API.  Please see our [API documentation](http://developer.zendesk.com) for more information.

## Additional Documentation

Additional documentation can be found on our [documentation site](https://zendesk-api.herokuapp.com/doc/index.html) and [wiki](https://github.com/zendesk/zendesk_api_client_rb/wiki).

## Important Notice

* Version 0.0.5 brings with it a change to the top-level namespace. All references to Zendesk should now use ZendeskAPI.
* Version 0.3.0 changed the license from MIT to Apache Version 2.

## Installation

The Zendesk API client can be installed using Rubygems or Bundler.

### Rubygems

```sh
gem install zendesk_api
```

### Bundler

Add it to your Gemfile

    gem "zendesk_api"

and follow normal [Bundler](http://gembundler.com/) installation and execution procedures.

## Configuration

Configuration is done through a block returning an instance of ZendeskAPI::Client.
The block is mandatory and if not passed, an ArgumentError will be thrown.

```ruby
require 'zendesk_api'

client = ZendeskAPI::Client.new do |config|
  # Mandatory:

  config.url = "<- your-zendesk-url ->" # e.g. https://mydesk.zendesk.com/api/v2

  config.username = "login.email@zendesk.com"

  # Choose one of the following depending on your authentication choice
  config.token = "your zendesk token"
  config.password = "your zendesk password"

  # Optional:

  # Retry uses middleware to notify the user
  # when hitting the rate limit, sleep automatically,
  # then retry the request.
  config.retry = true

  # Logger prints to STDERR by default, to e.g. print to stdout:
  require 'logger'
  config.logger = Logger.new(STDOUT)

  # Changes Faraday adapter
  # config.adapter = :patron

  # Merged with the default client options hash
  # config.client_options = { :ssl => false }

  # When getting the error 'hostname does not match the server certificate'
  # use the API at https://yoursubdomain.zendesk.com/api/v2
end
```

Note: This ZendeskAPI API client only supports basic authentication at the moment.

## Usage

The result of configuration is an instance of ZendeskAPI::Client which can then be used in two different methods.

One way to use the client is to pass it in as an argument to individual classes.

```ruby
ZendeskAPI::Ticket.new(client, :id => 1, :priority => "urgent") # doesn't actually send a request, must explicitly call #save
ZendeskAPI::Ticket.create(client, :subject => "Test Ticket", :comment => { :value => "This is a test" }, :submitter_id => client.current_user.id, :priority => "urgent")
ZendeskAPI::Ticket.find(client, :id => 1)
ZendeskAPI::Ticket.delete(client, :id => 1)
```

Another way is to use the instance methods under client.

```ruby
client.tickets.first
client.tickets.find(:id => 1)
client.tickets.create(:subject => "Test Ticket", :comment => { :value => "This is a test" }, :submitter_id => client.current_user.id, :priority => "urgent")
client.tickets.delete(:id => 1)
```

The methods under ZendeskAPI::Client (such as .tickets) return an instance of ZendeskAPI::Collection a lazy-loaded list of that resource.
Actual requests may not be sent until an explicit ZendeskAPI::Collection#fetch, ZendeskAPI::Collection#to_a, or an applicable methods such
as #each.

### Caveats

Resource updating is implemented by sending only the `changed?` attributes to the server (see `ZendeskAPI::TrackChanges`).
Unfortunately, this module only hooks into `Hash` meaning any changes to an `Array`not resulting in a new instance will not be tracked and sent.

```
zendesk_api_client_rb $ bundle console
> a = ZendeskAPI::Trackie.new(:tags => []).tap(&:clear_changes)
> a.changed?(:tags)
 => false
> a.tags << "my_new_tag"
 => ["my_new_tag"]
> a.changed?(:tags)
 => false
> a.tags += %w{my_other_tag}
 => ["my_new_tag", "my_other_tag"]
> a.changed?(:tags)
 => true
```

### Pagination

ZendeskAPI::Collections can be paginated:

```ruby
tickets = client.tickets.page(2).per_page(3)
next_page = tickets.next
previous_page = tickets.prev
```

Iteration over all resources and pages is handled by Collection#each_page

```ruby
client.tickets.each_page do |resource|
  # all resources will be yielded
end
```

If given a block with two arguments, the page is also passed in.

```ruby
client.tickets.each_page do |resource, page|
  # all resources will be yielded along with the page
end
```

### Callbacks

Callbacks can be added to the ZendeskAPI::Client instance and will be called (with the response env) after all response middleware on a successful request.

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
ticket.save # Will PUT => true
ticket.destroy # => true

ZendeskAPI::Ticket.new(client, { :priority => "urgent" })
ticket.new_record? # => true
ticket.save # Will POST
```

### Side-loading

**Warning: this is an experimental feature. Abuse it and lose it.**

To facilitate a smaller number of requests and easier manipulation of associated data we allow "side-loading", or inclusion, of selected resources.

For example:
A ZendeskAPI::Ticket is associated with ZendeskAPI::User through the requester_id field.
API requests for that ticket return a structure similar to this:
```json
"ticket": {
  "id": 1,
  "url": "http.....",
  "requester_id": 7,
  ...
}
```

Calling ZendeskAPI::Ticket#requester automatically fetches and loads the user referenced above (`/api/v2/users/7`).
Using side-loading, however, the user can be partially loaded in the same request as the ticket.

```ruby
tickets = client.tickets.include(:users)
# Or client.tickets(include: :users)
# Does *NOT* make a request to the server since it is already loaded
tickets.first.requester # => #<ZendeskAPI::User id=...>
```

OR

```ruby
ticket = client.tickets.find(:id => 1, :include => :users)
ticket.requester # => #<ZendeskAPI::User id=...>
```

Currently, this feature is limited to only a few resources and their associations.
They are documented on [developer.zendesk.com](http://developer.zendesk.com/documentation/rest_api/introduction.html#side-loading-\(beta\)).

### Search

Searching is done through the client. Returned is an instance of ZendeskAPI::Collection:

```ruby
client.search(:query => "my search query") # /api/v2/search.json?query=...
client.users.search(:query => "my new query")  # /api/v2/users/search.json?query=...
```

### Special case: Custom resources paths

API endpoints such as tickets/recent or topics/show_many can be accessed through chaining.
They will too return an instance of ZendeskAPI::Collection.

```ruby
client.tickets.recent
client.topics.show_many(:verb => :post, :ids => [1, 2, 3])
```

### Special Case: Current user

Use either of the following to obtain the current user instance:

```ruby
client.users.find(:id => 'me')
client.current_user
```

### Special Case: Importing a ticket

Bulk importing tickets allows you to move large amounts of data into Zendesk.

```ruby
ticket = ZendeskAPI::Ticket.import(client, :subject => "Help", :comments => [{ :author_id => 19, :value => "This is a comment" }])
```

http://developer.zendesk.com/documentation/rest_api/ticket_import.html

### Attaching files

Files can be attached to ticket comments using either a path or the File class and will
be automatically uploaded and attached.

```ruby
ticket = ZendeskAPI::Ticket.new(client, :comment => { :value => "attachments" })
ticket.comment.uploads << "img.jpg"
ticket.comment.uploads << File.new("img.jpg")
ticket.save
```

## Extras

The following projects are still works in progress and require checking out the repository,
using ruby 1.9.3, and running `bundle install`.

### Zendesk API Test Server

Included in this repository is the code for the [Zendesk API Tester](https://zendesk-api.herokuapp.com/) website.

```sh
bin/zendesk server --help
```

Additional Dependencies:

* sinatra
* sinatra-contrib
* haml
* compass
* coderay
* coderay_bash
* redcarpet
* mongoid (and a working MongoDB instance)

### Zendesk Console

WIP

```sh
bin/zendesk console --help
```

Additional Dependencies:

* ripl

## Note on Patches/Pull Requests
1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version
   unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have
   your own version, that is fine but bump version in a commit by itself I can
   ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

## Supported Ruby Versions

Tested with Ruby 1.8.7 and 1.9.3
[![Build Status](https://secure.travis-ci.org/zendesk/zendesk_api_client_rb.png?branch=master)](http://travis-ci.org/zendesk/zendesk_api_client_rb)

## Copyright and license

Copyright 2013 Zendesk

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

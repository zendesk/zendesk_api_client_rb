# Zendesk API Client

## Current version

The latest version is v0.0.8

## API version support

This client **only** supports Zendesk's v2 API.  Please see our [API documentation](http://developer.zendesk.com) for more information.

## Important Notice

Version 0.0.5 brings with it a change to the top-level namespace. All references to Zendesk should now use ZendeskAPI.

## Installation

Currently

    gem install zendesk_api

will not install this version of the API client. To install this client, either clone this repository and run

    rake install

or add it to a Gemfile like so:

    gem "zendesk_api", :git => "git://github.com/zendesk/zendesk_api_client_rb.git" #, :tag => "vX.X.X"

## Configuration

Configuration is done through a block returning an instance of ZendeskAPI::Client.
The block is mandatory and if not passed, an ArgumentError will be thrown.

```
ZendeskAPI::Client.new do |config|
  # Mandatory:

  config.url = "https://mydesk.zendesk.com/api/v2"

  config.username = "test.user"
  config.password = "test.password"

  # Optional:

  # Retry uses middleware to notify the user
  # when hitting the rate limit, sleep automatically,
  # then retry the request.
  config.retry = true

  # Logger prints to STDERR by default, to e.g. print to stdout:
  require 'logger'
  config.logger = Logger.new(STDOUT)

  # Changes Faraday adapter
  config.adapter = :patron

  # Merged with the default client options hash
  config.client_options = { :ssl => false }

  # When getting the error 'hostname does not match the server certificate' 
  # use the API at https://yoursubdomain.zendesk.com/api/v2
end
```

Note: This ZendeskAPI API client only supports basic authentication at the moment.

## Usage

The result of configuration is an instance of ZendeskAPI::Client which can then be used in two different methods.

One way to use the client is to pass it in as an argument to individual classes.

```
ZendeskAPI::Ticket.new(client, :id => 1, :priority => "urgent") # doesn't actually send a request, must explicitly call #save
ZendeskAPI::Ticket.create(client, :subject => "Test Ticket", :description => "This is a test", :submitter_id => client.current_user.id, :priority => "urgent")
ZendeskAPI::Ticket.find(client, :id => 1)
ZendeskAPI::Ticket.delete(client, :id => 1)
```

Another way is to use the instance methods under client.

```
client.tickets.first
client.tickets.find(:id => 1)
client.tickets.create(:subject => "Test Ticket", :description => "This is a test", :submitter_id => client.current_user.id, :priority => "urgent")
client.tickets.delete(:id => 1)
```

The methods under ZendeskAPI::Client (such as .tickets) return an instance of ZendeskAPI::Collection a lazy-loaded list of that resource.
Actual requests may not be sent until an explicit ZendeskAPI::Collection#fetch, ZendeskAPI::Collection#to_a, or an applicable methods such
as #each.

### Pagination

ZendeskAPI::Collections can be paginated:

```
tickets = client.tickets.page(2).per_page(3)
next_page = tickets.next
previous_page = tickets.prev
```

### Callbacks

Callbacks can be added to the ZendeskAPI::Client instance and will be called (with the response env) after all response middleware on a successful request.

```
client.insert_callback do |env|
  puts env[:response_headers]
end
```

### Resource management

Individual resources can be created, modified, saved, and destroyed.

```
ticket = client.tickets[0] # ZendeskAPI::Ticket.find(client, :id => 1)
ticket.priority = "urgent"
ticket.attributes # => { "priority" => "urgent" }
ticket.save # Will PUT => true
ticket.destroy # => true

ZendeskAPI::Ticket.new(client, { :priority => "urgent" })
ticket.new_record? # => true
ticket.save # Will POST
```

### Special case: playlists

Views can be played using different syntax than normal resources.
Playlists are started with:

```
client.play(id)
client.play('incoming')
```

OR

```
ZendeskAPI::Playlist.new(client, id)
```

Playlists are automatically started server-side when created and can then be played using the
ZendeskAPI::Playlist#next method. Also available is the ZendeskAPI::Playlist#each method which
takes a block and will successively get and yield each ticket until the end of the playlist.

```
playlist.each do |ticket|
  ticket.status = "solved"
  ticket.save
end
```

### Special case: Custom resources paths

API endpoints such as tickets/recent or topics/show_many can be accessed through chaining.
They will too return an instance of ZendeskAPI::Collection.

```
client.tickets.recent
client.topics.show_many(:verb => :post, :ids => [1, 2, 3])
```

### Special Case: Current user

Use either of the following to obtain the current user instance:

```
client.users.find(:id => 'me')
client.current_user
```

### Attaching files

Files can be attached to tickets using either a path or the File class and will
be automatically uploaded and attached.

```
ticket = Ticket.new(...)
ticket.uploads << "img.jpg"
ticket.uploads << File.new("img.jpg")
ticket.save
```

## TODO

* Search class detection
* Live Testing

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
[![Build Status](https://secure.travis-ci.org/zendesk/zendesk_api_client_rb.png)](http://travis-ci.org/zendesk/zendesk_api_client_rb)

## Copyright

See [LICENSE](https://github.com/zendesk/zendesk_api_client_rb/blob/master/LICENSE)

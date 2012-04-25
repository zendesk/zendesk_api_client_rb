# Zendesk API Client
## Configuration

Configuration is done through a block returning an instance of Zendesk::Client.
The block is mandatory and if not passed, a Zendesk::ConfigurationException will be thrown.

```
Zendesk.configure do |config|
  # Mandatory:

  # Must be https URL unless it is localhost or 127.0.0.1
  config.url = "https://mydesk.zendesk.com"

  config.username = "test.user"
  config.password = "test.password"

  # Optional:

  # Retry uses middleware to notify the user
  # when hitting the rate limit, sleep automatically,
  # then retry the request.
  config.retry = true
  # Log prints out requests to STDOUT
  config.log = true
end
```

Note: This Zendesk API client only supports basic authentication at the moment.

## Usage

The result of configuration is an instance of Zendesk::Client which can then be used in two different methods.

One way to use the client is to pass it in as an argument to individual classes.

```
Zendesk::Ticket.new(client, :id => 1, :priority => "urgent") # doesn't actually send a request, must explicitly call #save 
Zendesk::Ticket.create(client, :subject => "Test Ticket", :description => "This is a test", :submitter_id => client.me.id, :priority => "urgent")
Zendesk::Ticket.find(client, 1)
Zendesk::Ticket.delete(client, 1)
```

Another way is to use the instance methods under client.

```
client.tickets.first
client.tickets.find(1)
client.tickets.create(:subject => "Test Ticket", :description => "This is a test", :submitter_id => client.me.id, :priority => "urgent")
client.tickets.delete(1)
```

The methods under Zendesk::Client (such as .tickets) return an instance of Zendesk::Collection a lazy-loaded list of that resource. 
Actual requests may not be sent until an explicit Zendesk::Collection#fetch, Zendesk::Collection#to_a, or an applicable methods such
as #each.

### Pagination

Zendesk::Collections can be paginated:

```
tickets = client.tickets.page(2).per_page(3)
next_page = tickets.next
previous_page = tickets.prev
```

### Callbacks

Callbacks can be added to the Zendesk::Client instance and will be called (with the response env) after all response middleware.

```
client.insert_callback do |env|
  if env[:status] == 404
    puts "Invalid request"
  end
end
```

### Resource management

Individual resources can be created, modified, saved, and destroyed.

```
ticket = client.tickets[0] # Zendesk::Ticket.find(client, 1)
ticket.priority = "urgent"
ticket.attributes # => { "priority" => "urgent" }
ticket.save # => true
ticket.destroy # => true

Zendesk::Ticket.new(client, { :priority => "urgent" })
ticket.new_record? # => true
ticket.save # Will POST
```

## TODO

* Take a look at dynamic resources under Zendesk::Client
* Testing

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

## Copyright

See [LICENSE](LICENSE)

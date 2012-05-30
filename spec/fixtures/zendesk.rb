def user
  @user ||= find_or_create_user "end-user"
end

def current_user
  VCR.use_cassette('current_user') do
    @current_user ||= client.users.find(:id => 'me') 
  end
end

def agent
  @agent ||= find_or_create_user "agent"
end

def find_or_create_user(role)
  VCR.use_cassette("valid_user_#{role}") do
    email = "zendesk-api-client-ruby-#{role}-#{client.config.username}"

    client.users.detect {|u| u.email == email } ||
    client.users.create(
      :name => "Test Valid with role #{role}",
      :verified => true,
      :email => email,
      :role => role
    )
  end
end

def topic
  VCR.use_cassette('valid_topic') do
    @topic ||= forum.topics.first
    @topic ||= client.topics.create(
      :title => "Test Topic",
      :body => "This is the body of a topic.",
      :forum_id => forum.id
    )
  end
end

def forum
  VCR.use_cassette('valid_forum') do
    @forum ||= client.forums.detect {|f| f.topics.any? }
    @forum ||= client.forums.create(:name => "Test Forum", :access => "everybody")
  end
end

def category
  VCR.use_cassette('valid_category') do
    @category ||= client.categories.first
    @category ||= client.categories.create(:name => "Test Category")
  end
end

def ticket
  VCR.use_cassette('valid_ticket') do
    @ticket ||= client.tickets.first
    @ticket ||= client.tickets.create(
      :subject => "Test Ticket",
      :description => "This is a test of the emergency alert system.",
      :requester_id => user.id
    )
  end
end

def suspended_ticket
  VCR.use_cassette('valid_suspended_ticket') do
    @suspended_ticket ||= client.suspended_tickets.first
  end
end

def group
  VCR.use_cassette('valid_group') do
    @ticket ||= client.groups.detect {|g| !g.default}
    @ticket ||= client.groups.create(:name => "Test Group")
  end
end

def organization
  VCR.use_cassette('valid_organization') do
    @organization ||= current_user.organization 
  end
end

# Global default options, overwritten if using under
def default_options
  {}
end


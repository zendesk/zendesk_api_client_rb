def user
  VCR.use_cassette('valid_user') do
    @user ||= client.users.create(
      :user => {
        :name => "Test Valid User",
        :verified => true,
        :email => "test.valid.user@zendesk.com",
        :role => "end-user"
      } 
    ) || client.users.detect {|u| u.email == "test.valid.user@zendesk.com"}
  end
end

def current_user
  VCR.use_cassette('current_user') do
    @current_user ||= client.users.find('me') 
  end
end

def agent
  VCR.use_cassette('valid_agent') do
    @agent ||= client.users.create(
      :user => {
        :name => "Test Valid Agent",
        :verified => true,
        :email => "test.valid.agent@zendesk.com",
        :role => "agent"
      } 
    ) || client.users.detect {|u| u.email == "test.valid.agent@zendesk.com"}
  end
end

def topic
  VCR.use_cassette('valid_topic') do
    @topic ||= client.topics.create(
      :topic => {
        :title => "Test Topic",
        :body => "This is the body of a topic.",
        :forum_id => forum.id
      }
    ) || forum.topics.first 
  end
end

def forum
  VCR.use_cassette('valid_forum') do
    @forum ||= client.forums.create(
      :forum => {
        :name => "Test Forum",
        :access => "everybody"
      }
    ) || client.forums.detect {|f| f.topics.any?}
  end
end

def category
  VCR.use_cassette('valid_category') do
    @category ||= client.categories.create(
      :category => { :name => "Test Category" }
    ) || client.categories.first
  end
end

def ticket
  VCR.use_cassette('valid_ticket') do
    @ticket ||= client.tickets.create(
      :ticket => {
        :subject => "Test Ticket",
        :description => "This is a test of the emergency alert system.",
        :requester_id => user.id
      }
    ) || client.tickets.first
  end
end

def group
  VCR.use_cassette('valid_group') do
    @ticket ||= client.groups.create(
      :group => {
        :name => "Test Group"
      }
    ) || client.groups.detect {|g| !g.default}
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


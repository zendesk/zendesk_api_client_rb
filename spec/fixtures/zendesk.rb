module ZendeskAPI
  module Fixtures
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

        client.users.search(query: "email:#{email}").first ||
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
        @topic ||= client.topics.create(
          :name => "Test Topic",
          :description => "This is the body of a topic."
        )
      end
    end

    def category
      VCR.use_cassette('valid_category') do
        @category ||= client.categories.first
        @category ||= client.categories.create(:name => "Test Category")
      end
    end

    def section
      VCR.use_cassette('valid_section') do
        @section ||= client.sections.first
      end
    end

    def article
      VCR.use_cassette('valid_article') do
        @article ||= client.articles.first
      end
    end

    def ticket
      VCR.use_cassette('valid_ticket') do
        @ticket ||= client.tickets.detect { |t| t.status != 'closed' }
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
        @suspended_ticket ||= begin
          client.anonymous_requests.create(
            :subject => "Test Ticket",
            :comment => { :value => "Help! I need somebody." },
            :requester => { :email => "zendesk-api-client-ruby-anonymous-#{client.config.username}", :name => 'Anonymous User' }
          )
          client.suspended_tickets(:reload => true).first
        end
      end
    end

    def group
      VCR.use_cassette('valid_group') do
        @ticket ||= client.groups.detect { |g| !g.default }
        @ticket ||= client.groups.create(:name => "Test Group")
      end
    end

    def organization
      VCR.use_cassette('valid_organization') do
        @organization ||= current_user.organization
      end
    end

    def brand
      VCR.use_cassette('valid_brand') do
        @brand ||= client.brands.detect do |brand|
          client.config.url.start_with?(brand.brand_url)
        end
      end
    end

    def dynamic_content_item
      VCR.use_cassette('valid_dynamic_content') do
        @item ||= client.dynamic_content.items.first
        @item ||= client.dynamic_content.items.create!(:name => 'Test Item', :content => 'Testing', :default_locale_id => 1)
      end
    end
  end
end

require 'core/spec_helper'

describe ZendeskAPI::Ticket do
  def valid_attributes
    {
      :type => "question",
      :subject => "This is a question?",
      :comment => { :value => "Indeed it is!" },
      :priority => "normal",
      :requester_id => user.id,
      :submitter_id => user.id,
      :collaborator_ids => [agent.id]
    }
  end

  it_should_be_creatable
  it_should_be_updatable :subject
  it_should_be_deletable
  it_should_be_readable :tickets
  it_should_be_readable user, :requested_tickets
  it_should_be_readable agent, :ccd_tickets
  it_should_be_readable organization, :tickets

  context "recent tickets" do
    before(:each) do
      VCR.use_cassette("visit_recent_ticket") do
        client.connection.get("/tickets/1") do |req|
          req.headers[:Accept] = "*/*"
        end
      end
    end

    it_should_be_readable :tickets, :recent
  end

  describe ".incremental_export" do
    let(:results){ ZendeskAPI::Ticket.incremental_export(client, Time.at(1023059503)) } # ~ 10 years ago

    around do |example|
      # 1 request every 5 minutes allowed <-> you can only test 1 call ...
      VCR.use_cassette("incremental_export") do
        Timeout.timeout(5) do # fail if we get rate-limited
          example.call
        end
      end
    end

    it "finds tickets after a old date" do
      results.to_a.first.should be_an_instance_of ZendeskAPI::Ticket
    end

    it "is able to do next" do
      first = results.to_a.first
      stub_json_request(:get, %r{/api/v2/exports/tickets}, json(:results => []))

      results.next
      results.first.should_not == first
    end
  end

  describe ".import" do
    it "can import" do
      VCR.use_cassette("ticket_import_can_import") do
        old = Time.now - 5*365*24*60*60
        ticket = ZendeskAPI::Ticket.import(client, valid_attributes.merge(:created_at => old))
        ZendeskAPI::Ticket.find(client, ticket).created_at.year.should == old.year
      end
    end

    it "returns nothing if import fails" do
      VCR.use_cassette("ticket_import_cannot_import") do
        silence_logger { ZendeskAPI::Ticket.import(client, {}).should == nil }
      end
    end
  end

  it "can upload while creating" do
    VCR.use_cassette("ticket_inline_uploads") do
      ticket = ZendeskAPI::Ticket.new(client, valid_attributes.merge(default_options))
      ticket.comment.uploads << "spec/fixtures/Argentina.gif"
      ticket.comment.uploads << File.new("spec/fixtures/Argentina.gif")

      ticket.save!
      ticket.changes.should == {} # uploads were set before save
      ticket.comment.attributes[:uploads].map(&:class).should == [String, String] # upload was sent as tokens
    end
  end

  it "can comment while creating" do
    VCR.use_cassette("ticket_inline_comments") do
      ticket = ZendeskAPI::Ticket.new(client, valid_attributes.merge(default_options))
      ticket.comment = ZendeskAPI::Ticket::Comment.new(client, :value => "My comment", :public => false)
      ticket.save!

      ticket.changes.should == {} # comment was set before save
      ticket.attributes[:comment].should == {"value" => "My comment", "public" => false}
    end
  end

  describe "import race condition" do
    it "should handle it" do
      email = "test+#{rand(100000)}@test.com"

      VCR.use_cassette("ticket_import_race") do
        threads = []

        3.times do
          threads << Thread.new do
            client.insert_callback do |response|
              Thread.current[:response] = response
            end

            ZendeskAPI::Ticket.import(client, :requester => { :email => email, :name => "Hello" }, :subject => "Test", :description => "Test")
          end
        end

        threads.map! do |thread|
          thread.join(3)
          thread[:response][:status]
        end

        threads.all? {|st| [201, 422, 409].include?(st)}.should be_true
      end
    end
  end
end

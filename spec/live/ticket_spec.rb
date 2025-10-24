require 'core/spec_helper'

RSpec.describe ZendeskAPI::Ticket do
  def valid_attributes
    {
      :type => "question",
      :subject => "This is a question?",
      :comment => { :value => "Indeed it is!" },
      :priority => "normal",
      :requester_id => user.id,
      :assignee_id => current_user.id,
      :submitter_id => user.id,
      :collaborator_ids => [agent.id],
      :tags => %w(awesome blossom),
      :email_ccs => [
        { :user_id => agent.id, action: "put" }
      ]
    }
  end

  it_should_be_creatable
  it_should_be_updatable :subject
  it_should_be_deletable
  it_should_be_readable :tickets
  it_should_be_readable user, :requested_tickets
  it_should_be_readable current_user, :assigned_tickets, create: true
  it_should_be_readable agent, :ccd_tickets, create: true
  it_should_be_readable organization, :tickets

  describe "#create" do
    context "when passing large objects as parameters" do
      let(:requester) { client.users.search(query: 'role:end-user').detect(&:photo) }
      let(:organization) { client.organizations.sample }
      let(:ticket_parameters) do
        {
          subject: 'live spec subject',
          description: 'live spec description',
          requester: requester,
          organization: organization
        } # We should always use requester/organiztion _id for existing records. This test should not be used as a guideline on how to use the sdk.
      end

      before do
        VCR.use_cassette("ticket_create_with_large_objects") do
          @ticket = ZendeskAPI::Ticket.create(client, ticket_parameters)
        end
      end

      it 'is creatable' do
        expect(requester).to_not be_nil

        expect(@ticket.id).to_not be_nil
        expect(@ticket.description).to eq(ticket_parameters[:description])
      end
    end

    after do
      return unless @ticket
      VCR.use_cassette("ticket_destroy_with_large_objects") do
        @ticket.destroy!
      end
    end
  end

  describe "#show_many" do
    let(:how_many_tickets) { 10 }
    before do
      VCR.use_cassette("get_tickets_show_many") do
        @tickets = client.tickets.per_page(how_many_tickets).fetch
      end

      VCR.use_cassette("tickets_show_many_with_ids") do
        @tickets_from_show_many = client.tickets.show_many(ids: @tickets.map(&:id)).fetch
      end
    end

    it "returns the correct number of tickets" do
      expect(@tickets_from_show_many.count).to eq(how_many_tickets)
      expect(@tickets.map(&:id).sort).to eq(@tickets_from_show_many.map(&:id).sort)
    end
  end

  describe "#attributes_for_save" do
    let :ticket do
      described_class.new(instance_double(ZendeskAPI::Client), status: :new)
    end

    it "keeps all the comments", :vcr do
      ticket.update(comment: { private: true, body: "Private comment" })
      expect(ticket.attributes_for_save).to eq(ticket: {
                                                 "status" => :new,
                                                 "comment" => { "private" => true, "body" => "Private comment" }
                                               })

      ticket.update(comment: { private: true, body: "Private comment2" })
      expect(ticket.attributes_for_save).to eq(ticket: {
                                                 "status" => :new,
                                                 "comment" => { "private" => true, "body" => "Private comment2" }
                                               })
    end
  end

  context "recent tickets" do
    before(:all) do
      VCR.use_cassette("visit_recent_ticket") do
        client.tickets.find(id: 1)

        sleep(5)
      end
    end

    it_should_be_readable :tickets, :recent
  end

  describe ".incremental_export" do
    let(:results) { ZendeskAPI::Ticket.incremental_export(client, Time.at(1023059503)) } # ~ 10 years ago

    around do |example|
      # 1 request every 5 minutes allowed <-> you can only test 1 call ...
      VCR.use_cassette("incremental_export") do
        client.config.retry = false

        example.call

        client.config.retry = true
      end
    end

    it "finds tickets after a old date" do
      expect(results.to_a.first).to be_an_instance_of ZendeskAPI::Ticket
    end

    it "is able to do next" do
      first = results.to_a.first
      stub_json_request(:get, %r{/api/v2/incremental/tickets}, json(:results => []))

      results.next
      expect(results.first).to_not eq(first)
    end
  end

  describe ".import" do
    it "can import" do
      VCR.use_cassette("ticket_import_can_import") do
        old = Time.now - (5 * 365 * 24 * 60 * 60)
        ticket = ZendeskAPI::Ticket.import(client, valid_attributes.merge(:created_at => old.iso8601))
        expect(ZendeskAPI::Ticket.find(client, :id => ticket.id).created_at.year).to eq(old.year)
      end
    end

    it "returns nothing if import fails" do
      VCR.use_cassette("ticket_import_cannot_import") do
        silence_logger { expect(ZendeskAPI::Ticket.import(client, {})).to eq(nil) }
      end
    end
  end

  it "can upload while creating" do
    VCR.use_cassette("ticket_inline_uploads") do
      ticket = ZendeskAPI::Ticket.new(client, valid_attributes)
      ticket.comment.uploads << "spec/fixtures/Argentina.gif"
      ticket.comment.uploads << File.new("spec/fixtures/Argentina.gif")

      ticket.save!
      expect(ticket.changes).to eq({}) # uploads were set before save
      expect(ticket.comment.attributes[:uploads].map(&:class)).to eq([String, String]) # upload was sent as tokens
    end
  end

  it "can comment while creating" do
    VCR.use_cassette("ticket_inline_comments") do
      ticket = ZendeskAPI::Ticket.new(client, valid_attributes)
      ticket.comment = ZendeskAPI::Ticket::Comment.new(client, :value => "My comment", :public => false)
      ticket.save!

      expect(ticket.changes).to eq({}) # comment was set before save
      expect(ticket.attributes[:comment]).to eq({ "value" => "My comment", "public" => false })
    end
  end

  describe "import race condition" do
    let(:email) { "test+#{rand(100000)}@test.com" }

    it "should handle it" do
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
          thread.join(5)
          fail("could not get response in 5 seconds") unless thread[:response]
          thread[:response][:status]
        end

        user = client.users.detect { |user| user.email == email }
        expect(user).to_not be_nil

        user.requested_tickets.each(&:destroy)
        user.destroy

        expect(threads.all? { |st| [201, 422, 409].include?(st) }).to be(true)
      end
    end
  end

  describe "CustomFieldSymbolProxy" do
    let(:field_metadata) do
      [
        { id: 1, title: "foo" },
        { id: 2, title: "bar" }
      ]
    end
    let(:client) do
      double("Client", :instance_variable_get => field_metadata)
    end
    let(:ticket) do
      t = ZendeskAPI::Ticket.allocate
      t.instance_variable_set(:@client, client)
      t.instance_variable_set(:@custom_fields, [{ id: 1, value: "abc" }])
      t
    end
    let(:proxy) { ZendeskAPI::Ticket::CustomFieldSymbolProxy.new(ticket, nil) }

    it "reads a custom field by symbol" do
      expect(proxy["foo"]).to eq("abc")
    end

    it "raises error for missing field" do
      expect { proxy["baz"] }.to raise_error(/Cannot find custom field/)
    end

    it "writes a custom field by symbol" do
      proxy["bar"] = "def"
      expect(ticket.custom_fields.find { |h| h[:id] == 2 }[:value]).to eq("def")
    end

    it "delegates to_a" do
      expect(proxy.to_a).to eq(ticket.custom_fields)
    end

    it "delegates method_missing and respond_to_missing?" do
      expect(proxy.respond_to?(:each)).to be true
      expect(proxy.map { |h| h[:id] }).to eq([1])
    end

    describe "integration with Ticket methods" do
      it "returns proxy from custom_field_symbol accessor" do
        t = ZendeskAPI::Ticket.allocate
        t.instance_variable_set(:@client, client)
        t.instance_variable_set(:@custom_fields, [{ id: 1, value: "abc" }])
        expect(t.custom_field_symbol["foo"]).to eq("abc")
      end

      it "updates proxy on custom_field_symbol= assignment" do
        t = ZendeskAPI::Ticket.allocate
        t.instance_variable_set(:@client, client)
        t.custom_field_symbol = [{ id: 1, value: "xyz" }]
        expect(t.custom_field_symbol.to_a).to eq([{ id: 1, value: "xyz" }])
      end
    end
  end
end

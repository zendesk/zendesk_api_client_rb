require_relative "../core/resources/cbp_spec_helper"

describe "Endpoints that support CBP" do
  describe ZendeskAPI::Group do
    describe "/groups" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.groups }
      end
    end

    describe "/groups/assignable" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.groups.assignable }
      end
    end
  end

  describe ZendeskAPI::GroupMembership do
    describe "/groups/:id/memberships" do
      let(:one_group) { VCR.use_cassette("cbp_group_memberships_all_groups") { client.groups.fetch.last } }
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { one_group.memberships }
      end
    end
  end

  describe ZendeskAPI::Organization do
    describe "/organizations" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.organizations }
      end
    end
  end

  describe ZendeskAPI::OrganizationMembership do
    describe "/organizations/:id/subscriptions" do
      let(:one_organization) { VCR.use_cassette("cbp_organization_subscriptions_all_organizations") { client.organizations.fetch.last } }
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { one_organization.subscriptions }
      end
    end
  end

  describe ZendeskAPI::Trigger do
    describe "/triggers" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.triggers }
      end
    end

    describe "/triggers/active" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.triggers.active }
      end
    end
  end

  describe ZendeskAPI::TicketField do
    describe "/ticket_fields" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.ticket_fields }
      end
    end
  end

  describe ZendeskAPI::Topic do
    describe "/community/topics" do
      let(:collection_fetched) do
        VCR.use_cassette("cbp_#{described_class}_collection_fetch") do
          client.topics.fetch
          client.topics
        end
      end

      let(:response_body) { collection_fetched.response.body }
      let(:collection_fetched_results) { collection_fetched.to_a }

      it "returns a CBP response with all the correct keys" do
        expect(response_body).to have_key("meta")
        expect(response_body).to have_key("links")
        expect(response_body["meta"].keys).to match_array(%w[has_more after_cursor before_cursor])
        # expect(response_body['links'].keys).to match_array(%w[prev next]) this implementation omits prev and next keys
        # instead of giving them a nil value
      end

      it "returns a list of #{described_class} objects" do
        expect(collection_fetched_results).to all(be_a(described_class))
      end
    end
  end

  describe ZendeskAPI::View do
    describe "/views" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.views }
      end
    end
  end

  describe ZendeskAPI::Ticket do
    describe "/tickets" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.tickets }
      end
    end

    describe "/organizations/:id/tickets" do
      let(:organization) do
        VCR.use_cassette("cbp_#{described_class}_organization_fetch") do
          client.organizations.fetch.first
        end
      end

      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { organization.tickets }
      end
    end

    describe "/users/:id/tickets/requested" do
      let(:user) do
        VCR.use_cassette("cbp_#{described_class}_user_fetch") do
          client.users.fetch.first
        end
      end

      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { user.requested_tickets }
      end
    end
  end

  describe ZendeskAPI::Ticket::Audit do
    describe "/tickets/:id/audits" do
      let(:ticket) do
        VCR.use_cassette("cbp_#{described_class}_ticket_fetch") do
          client.tickets.fetch.first
        end
      end

      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { ticket.audits }
      end
    end
  end

  describe ZendeskAPI::TicketMetric do
    describe "/ticket_metrics" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.ticket_metrics }
      end
    end
  end

  describe ZendeskAPI::Tag do
    describe "/tags" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.tags }
      end
    end
  end

  describe ZendeskAPI::SuspendedTicket do
    describe "/suspended_tickets" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.suspended_tickets }
      end
    end
  end

  describe ZendeskAPI::Activity do
    describe "/activities" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.activities }
      end
    end
  end

  describe ZendeskAPI::Automation do
    describe "/automations" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.automations }
      end
    end
  end

  describe ZendeskAPI::DeletedTicket do
    describe "/deleted_tickets" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.deleted_tickets }
      end
    end
  end

  describe ZendeskAPI::Macro do
    describe "/macros" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.macros }
      end
    end
  end

  describe ZendeskAPI::OauthClient do
    describe "/oauth/clients" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.oauth_clients }
      end
    end
  end

  describe ZendeskAPI::Brand do
    describe "/brands" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.brands }
      end
    end
  end

  describe ZendeskAPI::User do
    describe "/users" do
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { client.users }
      end
    end

    describe "/organizations/:id/users" do
      let(:organization) do
        VCR.use_cassette("cbp_#{described_class}_organization_fetch") do
          client.organizations.fetch.first
        end
      end
      it_behaves_like "an endpoint that supports CBP" do
        let(:collection) { organization.users }
      end
    end
  end

  describe ZendeskAPI::AgentAvailability do
    describe "/agent_availabilities" do
      let(:collection_fetched) do
        VCR.use_cassette("cbp_#{described_class}_collection") do
          client.agent_availabilities.fetch
          client.agent_availabilities
        end
      end

      let(:response_body) { collection_fetched.response.body }
      let(:collection_fetched_results) { collection_fetched.to_a }
      it "returns a CBP response with all the correct keys" do
        expect(response_body).to have_key("meta")
        expect(response_body).to have_key("links")
        expect(response_body["meta"].keys).to include("has_more")
      end

      it "returns a list of AgentAvailability objects" do
        expect(collection_fetched_results).to all(be_a(described_class))
      end
    end
  end
end

require 'core/spec_helper'
require 'core/resources/cbp_spec_helper'

describe 'Endpoints that support CBP' do
  describe ZendeskAPI::Group do
    describe '/groups' do
      it_behaves_like 'an endpoint that supports CBP' do
        let(:collection) { client.groups }
      end
    end

    describe '/groups/assignable' do
      it_behaves_like 'an endpoint that supports CBP' do
        let(:collection) { client.groups.assignable }
      end
    end
  end

  describe ZendeskAPI::GroupMembership do
    describe '/groups/:id/memberships' do
      let(:one_group) { VCR.use_cassette("cbp_group_memberships_all_groups") { client.groups.fetch.last } }
      it_behaves_like 'an endpoint that supports CBP' do
        let(:collection) { one_group.memberships }
      end
    end
  end

  describe ZendeskAPI::Organization do
    describe '/organizations' do
      it_behaves_like 'an endpoint that supports CBP' do
        let(:collection) { client.organizations }
      end
    end
  end

  describe ZendeskAPI::OrganizationMembership do
    describe '/organizations/:id/subscriptions' do
      let(:one_organization) { VCR.use_cassette("cbp_organization_subscriptions_all_organizations") { client.organizations.fetch.last } }
      it_behaves_like 'an endpoint that supports CBP' do
        let(:collection) { one_organization.subscriptions }
      end
    end
  end

  describe ZendeskAPI::Trigger do
    describe '/triggers' do
      it_behaves_like 'an endpoint that supports CBP' do
        let(:collection) { client.triggers }
      end
    end

    describe '/triggers/active' do
      it_behaves_like 'an endpoint that supports CBP' do
        let(:collection) { client.triggers.active }
      end
    end
  end
end

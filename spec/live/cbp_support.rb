require 'core/spec_helper'
require 'core/cbp_helper'
describe 'Endpoints that support CBP' do
  describe ZendeskAPI::Group do
    describe '/groups' do
      expect_cbp_response_for(client.groups)
      expect_cbp_response_for(client.groups.assignable)
    end
  end

  describe ZendeskAPI::GroupMembership do
    describe '/groups/{id}/memberships' do
      before do
        VCR.use_cassette("cbp_group_memberships_all_groups") do
          @groups = client.groups.fetch
        end

        VCR.use_cassette("cbp_group_memberships_for_a_group") do
          @memberships_collection = @groups.last.memberships
          @all_memberships = @memberships_collection.fetch
          @response_body = @memberships_collection.response.body
        end
      end

      it 'expects an array with the correct element types' do
        expect(@all_memberships).to all(be_a(ZendeskAPI::GroupMembership))
      end

      it 'expects a CBP response with all the correct keys' do
        expect(@response_body).to have_key('meta')
        expect(@response_body).to have_key('links')
        expect(@response_body['meta'].keys).to match_array(%w[has_more after_cursor before_cursor])
        expect(@response_body['links'].keys).to match_array(%w[prev next])
      end
    end
  end
end

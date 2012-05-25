require 'spec_helper'

# Would be nice to test this in real way.
#
# For example:
# 1) in block 'before' - find or create new user with sample email
# 2) set this sample email to client #on_behalf_of
# 3) check, that when user finds self - will see new sample email
describe 'Behave as different user than authenticated' do
  use_vcr_cassette
  let(:email) { 'super.valid.email@example.com' }

  pending "we could not find user by their email/name" do
    before do
      client.users.create :user => { :username => email } unless client.users.find(:email => email)
      client.config.on_behalf_of = email
    end

    it 'should properly set header X-On-Behalf-Of' do
      client.users.find(:id => :me).config.username.should == email
    end
  end
end

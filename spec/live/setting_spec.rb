require 'core/spec_helper'

describe ZendeskAPI::Setting do
  it_should_be_readable :settings, :path => 'account/settings'

  under (user = ZendeskAPI::User.new(client, :id => 'me')) do
    it_should_be_readable user, :settings

    describe 'updating', :vcr do
      it 'should be updatable' do
        settings = user.settings
        lotus = settings.detect {|set| set.on == "lotus"}

        original_setting = lotus.keyboard_shortcuts_enabled
        lotus.keyboard_shortcuts_enabled = !original_setting

        settings.save!
        settings.fetch!(true)

        lotus = settings.detect {|set| set.on == "lotus"}
        lotus.keyboard_shortcuts_enabled.should == !original_setting
      end
    end
  end
end

require 'core/spec_helper'
require 'securerandom'

describe ZendeskAPI::CustomStatus, :delete_after do
  def valid_attributes
    {
      status_category: 'open',
      agent_label: "Agent Label #{SecureRandom.hex(6)}",
      end_user_label: "End User Label #{SecureRandom.hex(6)}",
      description: "Description #{SecureRandom.hex(6)}",
      end_user_description: "End User Description #{SecureRandom.hex(6)}",
      active: false
    }
  end

  it_should_be_creatable
  it_should_be_updatable :agent_label, "ruby_sdk_test_agent_label_updated"
  it_should_be_updatable :end_user_label, 'New End User Label'
  it_should_be_updatable :description, 'New Description'
  it_should_be_updatable :end_user_description, 'New End User Description'
  it_should_be_deletable find: [:active?, false]
  it_should_be_readable :custom_statuses
end

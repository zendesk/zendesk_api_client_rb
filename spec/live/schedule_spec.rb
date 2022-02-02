require 'core/spec_helper'

RSpec.describe ZendeskAPI::Schedule, :delete_after do
  def valid_attributes
    {
      name: "Brit Schedule",
      time_zone: "London"
    }
  end

  it_should_be_creatable
end

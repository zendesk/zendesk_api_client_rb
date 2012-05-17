require 'spec_helper'

describe Zendesk::Audit do
  it_should_be_readable ticket, :audits
end

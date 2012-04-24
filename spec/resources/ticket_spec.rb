require 'spec/spec_helper'

describe Zendesk::Ticket do
  use_vcr_cassette :record => :new_episodes

  let(:client) { valid_client }
  let(:requester) { client.users.first }
  subject do
    Zendesk::Ticket.create(client, :ticket => {
      :type => "question",
      :subject => "This is a question?",
      :description => "Indeed it is!",
      :priority => "normal",
      :requester_id => requester.id,
      :submitter_id => requester.id
    })
  end

  it "should be able to access underlying attributes" do
    expect { subject.priority = "urgen" }.to_not raise_error
  end

  it "should be able to iterate over underlying attributes" do
    expect {
      subject.map do |k, v|
        [k.to_sym, v]
      end
    }.to_not raise_error
  end

  context "updating attributes" do
    before(:each) { subject.priority = "urgent" }

    it "should save ticket" do
      subject.save.should be_true
      subject.priority.should == "urgent"
    end
  end
end

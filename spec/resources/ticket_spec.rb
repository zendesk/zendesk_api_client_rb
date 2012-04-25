require 'spec_helper'

describe Zendesk::Ticket do
  use_vcr_cassette

  let(:client) { valid_client }
  let(:requester) { client.users.first }
  before(:all) do
    VCR.use_cassette('create_ticket') do
      @ticket = Zendesk::Ticket.create(client, :ticket => {
        :type => "question",
        :subject => "This is a question?",
        :description => "Indeed it is!",
        :priority => "normal",
        :requester_id => requester.id,
        :submitter_id => requester.id,
      })
    end
  end

  subject { Zendesk::Ticket.find(client, @ticket.id) }

  it "should have an id" do
    subject.id.should_not be_nil
  end

  context "updating attributes" do
    before(:each) { subject.priority = "urgent" }

    it "should save ticket" do
      subject.save.should be_true
      subject.priority.should == "urgent"
    end
  end

  context "client.tickets" do
    it "should include created ticket" do
      client.tickets.should include(@ticket)
    end
  end

  context "associations" do
    context "audits" do
    end
  end
end

describe "Ticket destruction" do
  use_vcr_cassette

  let(:client) { valid_client }
  let(:requester) { client.users.first }

  before(:all) do
    VCR.use_cassette('create_ticket') do
      @ticket = Zendesk::Ticket.create(client, :ticket => {
        :type => "question",
        :subject => "This is a question?",
        :description => "Indeed it is!",
        :priority => "normal",
        :requester_id => requester.id,
      })
    end
  end

  it "should be able to be destroyed" do
    @ticket.destroy.should be_true
    @ticket.destroyed?.should be_true

    client.tickets.fetch(true).should_not include(@ticket)
  end
end

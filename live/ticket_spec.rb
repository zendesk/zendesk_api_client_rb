require 'spec_helper'

describe Zendesk::Ticket do
  def valid_attributes
    { 
      :type => "question",
      :subject => "This is a question?",
      :description => "Indeed it is!",
      :priority => "normal",
      :requester_id => user.id,
      :submitter_id => user.id
    }
  end

  it_should_be_creatable
  it_should_be_updatable :subject
  it_should_be_deletable
  it_should_be_readable :tickets
  it_should_be_readable :tickets, :recent
  it_should_be_readable user, :requested_tickets
  it_should_be_readable user, :ccd_tickets
  it_should_be_readable organization, :tickets

  describe ".incremental_export" do
    let(:results){ Zendesk::Ticket.incremental_export(client, Time.at(1023059503)) } # ~ 10 years ago

    around do |example|
      # 1 request every 5 minutes allowed <-> you can only test 1 call ...
      VCR.use_cassette("incremental_export") do
        Timeout.timeout(5) do # fail if we get rate-limited
          example.call
        end
      end
    end

    it "finds tickets after a old date" do
      results.to_a.first.should be_an_instance_of Zendesk::Ticket
    end

    it "is able to do next" do
      first = results.to_a.first
      recent_url = "api/v2/exports/tickets.json?start_time=#{Time.now.to_i.to_s[0..5]}"
      response = mock(:body => {"results" => []})
      client.connection.should_receive(:get).with{|url| url.include?(recent_url) }.and_return response

      results.next
      results.first.should_not == first
    end
  end
end

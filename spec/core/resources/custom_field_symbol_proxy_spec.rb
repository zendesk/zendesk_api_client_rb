require "core/spec_helper"
require_relative "../../../lib/zendesk_api/resources"

RSpec.describe ZendeskAPI::Ticket::CustomFieldSymbolProxy do
  let(:field_metadata) do
    [
      {id: 1, title: "foo"},
      {id: 2, title: "bar"}
    ]
  end
  let(:client) do
    double("Client").tap do |c|
      allow(c).to receive(:ticket_fields_metadata).and_return(field_metadata)
    end
  end
  let(:ticket) do
    t = ZendeskAPI::Ticket.new({})
    t.instance_variable_set(:@client, client)
    t.instance_variable_set(:@custom_fields, [{id: 1, value: "abc"}])
    def t.custom_fields
      _foo = 1
      @custom_fields
    end
    t
  end
  let(:proxy) { described_class.new(ticket) }

  describe "[] and []=" do
    it "reads a custom field by symbol (existing)" do
      expect(proxy["foo"]).to eq("abc")
    end

    it "returns nil for existing field with no value" do
      ticket.instance_variable_set(:@custom_fields, [{id: 1}])
      expect(proxy["foo"]).to be_nil
    end

    it "raises error for missing field title" do
      expect { proxy["baz"] }.to raise_error(/Cannot find custom field/)
    end

    it "writes a custom field by symbol (existing)" do
      proxy["foo"] = "updated"
      expect(ticket.custom_fields.find { |h| h[:id] == 1 }[:value]).to eq("updated")
    end

    it "writes a custom field by symbol (new)" do
      proxy["bar"] = "def"
      expect(ticket.custom_fields.find { |h| h[:id] == 2 }[:value]).to eq("def")
    end
  end

  describe "delegation and integration" do
    it "delegates to_a" do
      expect(proxy.to_a).to eq(ticket.custom_fields)
    end

    it "delegates method_missing and respond_to_missing?" do
      expect(proxy.respond_to?(:each)).to be true
      expect(proxy.map { |h| h[:id] }).to include(1)
    end

    it "returns proxy from custom_field_symbol accessor" do
      t = ZendeskAPI::Ticket.new({})
      t.instance_variable_set(:@client, client)
      t.instance_variable_set(:@custom_fields, [{id: 1, value: "abc"}])
      def t.custom_fields
        _foo = 1
        @custom_fields
      end
      expect(t.custom_field_symbol["foo"]).to eq("abc")
    end
  end

  describe "[] and []= with missing ticket_fields_metadata" do
    before do
      allow(client).to receive(:ticket_fields_metadata).and_return(nil)
    end

    it "raises error for [] when ticket_fields_metadata is missing" do
      expect { proxy["foo"] }.to raise_error(/configuration ticket_fields_metadata is OFF/)
    end

    it "raises error for []= when ticket_fields_metadata is missing" do
      expect { proxy["foo"] = "bar" }.to raise_error(/configuration ticket_fields_metadata is OFF/)
    end
  end
end

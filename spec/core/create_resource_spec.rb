describe ZendeskAPI::CreateResource do
  context "create" do
    let(:attr) { {test_field: "blah"} }
    subject { ZendeskAPI::TestResource }

    before(:each) do
      stub_request(:post, %r{test_resources}).to_return(body: json)
    end

    it "should return instance of resource" do
      expect(subject.create(client, attr)).to be_instance_of(subject)
    end

    context "with client error" do
      before(:each) do
        stub_request(:post, %r{test_resources}).to_return(status: 500)
      end

      it "should handle it properly" do
        expect { silence_logger { expect(subject.create(client, attr)).to be_nil } }.to_not raise_error
      end
    end
  end

  context "create!" do
    subject { ZendeskAPI::TestResource }

    before(:each) do
      stub_request(:post, %r{test_resources}).to_return(status: 500)
    end

    it "should raise if save fails" do
      expect { subject.create!(client, test_field: "blah") }.to raise_error(ZendeskAPI::Error::NetworkError)
    end
  end
end

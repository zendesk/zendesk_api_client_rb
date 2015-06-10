require 'core/spec_helper'

describe ZendeskAPI::DestroyMany do
  subject { ZendeskAPI::BulkTestResource }

  context "destroy_many!" do
    before(:each) do
      stub_json_request(:delete, %r{bulk_test_resources/destroy_many}, json(:job_status => {:id => 'abc'}))
    end

    it 'calls the destroy_many endpoint' do
      subject.destroy_many!(client, [1,2,3])
      assert_requested(:delete, %r{bulk_test_resources/destroy_many\?ids%5B%5D=1&ids%5B%5D=2&ids%5B%5D=3})
    end
  end
end

describe ZendeskAPI::CreateMany do
  subject { ZendeskAPI::BulkTestResource }

  context "create_many!" do
    let(:attributes) { [{:name => 'A'}, {:name => 'B'}] }
    before(:each) do
      stub_json_request(:post, %r{bulk_test_resources/create_many}, json(:job_status => {:id => 'abc'}))
    end

    it 'calls the create_many endpoint' do
      subject.create_many!(client, attributes)
      assert_requested(:post, %r{bulk_test_resources/create_many},
        :body => json(:bulk_test_resources => attributes)
      )
    end
  end
end

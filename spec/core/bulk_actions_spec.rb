require 'core/spec_helper'

describe ZendeskAPI::DestroyMany do
  subject { ZendeskAPI::BulkTestResource }

  context "destroy_many!" do
    before(:each) do
      stub_json_request(:delete, %r{bulk_test_resources/destroy_many}, json(:job_status => { :id => 'abc' }))
      @response = subject.destroy_many!(client, [1, 2, 3])
    end

    it 'calls the destroy_many endpoint' do
      assert_requested(:delete, %r{bulk_test_resources/destroy_many\?ids=1,2,3$})
    end

    it 'returns a JobStatus' do
      expect(@response).to be_instance_of(ZendeskAPI::JobStatus)
      expect(@response.id).to eq('abc')
    end
  end
end

describe ZendeskAPI::CreateMany do
  subject { ZendeskAPI::BulkTestResource }

  context "create_many!" do
    let(:attributes) { [{ :name => 'A' }, { :name => 'B' }] }

    before(:each) do
      stub_json_request(:post, %r{bulk_test_resources/create_many}, json(:job_status => { :id => 'def' }))
      @response = subject.create_many!(client, attributes)
    end

    it 'calls the create_many endpoint' do
      assert_requested(:post, %r{bulk_test_resources/create_many},
        :body => json(:bulk_test_resources => attributes)
      )
    end

    it 'returns a JobStatus' do
      expect(@response).to be_instance_of(ZendeskAPI::JobStatus)
      expect(@response.id).to eq('def')
    end
  end

  describe ZendeskAPI::UpdateMany do
    subject { ZendeskAPI::BulkTestResource }

    context "update_many!" do
      context "arity: 3" do
        let(:attributes) { { :name => 'A', :age => 25 } }

        before(:each) do
          stub_json_request(:put, %r{bulk_test_resources/update_many}, json(:job_status => { :id => 'ghi' }))
          @response = subject.update_many!(client, [1, 2, 3], attributes)
        end

        it 'calls the update_many endpoint' do
          assert_requested(:put, %r{bulk_test_resources/update_many\?ids=1,2,3$},
            :body => json(:bulk_test_resource => attributes)
          )
        end

        it 'returns a JobStatus' do
          expect(@response).to be_instance_of(ZendeskAPI::JobStatus)
          expect(@response.id).to eq('ghi')
        end
      end

      context "arity: 2" do
        let(:attributes_array) { [{ :id => 1, :name => 'A' }, { :id => 2, :name => 'B' }] }

        before(:each) do
          stub_json_request(:put, %r{bulk_test_resources/update_many}, json(:job_status => { :id => 'jkl' }))
          @response = subject.update_many!(client, attributes_array)
        end

        it 'calls the update_many endpoint' do
          assert_requested(:put, %r{bulk_test_resources/update_many$},
            :body => json(:bulk_test_resources => attributes_array)
          )
        end

        it 'returns a JobStatus' do
          expect(@response).to be_instance_of(ZendeskAPI::JobStatus)
          expect(@response.id).to eq('jkl')
        end
      end
    end
  end
end

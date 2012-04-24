require 'spec/spec_helper'

describe Zendesk::Resource do
  let(:client) { valid_client }

  context "destroy", :vcr_off do
    context "class method" do
      let(:id) { 1 }
      subject { Zendesk::TestResource }

      before(:each) do
        stub_request(:delete, %r{test_resources/#{id}}).to_return({})
      end

      it "should return instance of resource" do
        subject.destroy(client, id).should be_true
      end

      context "with client error" do
        before(:each) do
          stub_request(:delete, %r{test_resources/#{id}}).to_return(:status => 500)
        end

        it "should handle it properly" do
          expect { subject.destroy(client, id).should be_false }.to_not raise_error
        end
      end
    end
  end

  context "update", :vcr_off do
  end

  %w{put post delete}.each do |verb|
    context "on #{verb}", :vcr_off do
      let(:method) { "test_#{verb}_method" }
      before(:each) do
        Zendesk::TestResource.send(verb, method)
      end

      context "class method" do
        subject { Zendesk::TestResource }

        it "should create a method of the same name" do
          subject.instance_methods.should include(method)
        end
      end

      context "instance method" do
        subject { Zendesk::TestResource.new(client, :id => 1) }

        before(:each) do
          stub_request(verb.to_sym, %r{test_resources/1/#{method}}).to_return(:body => { "test_resources" => [{ "id" => 1, "method" => method }]})
        end

        it "should return true" do
          subject.send(method).should be_true
        end

        it "should update the attributes if they exist" do
          subject.send(method)
          subject[:method].should == method
        end

        context "with client error" do
          before(:each) do
            stub_request(verb.to_sym, %r{test_resources/1/#{method}}).to_return(:status => 500)
          end

          it "should return false" do
            expect { subject.send(method).should be_false }.to_not raise_error
          end
        end
      end
    end
  end
end

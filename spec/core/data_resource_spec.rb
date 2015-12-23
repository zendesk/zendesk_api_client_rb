require 'core/spec_helper'

describe ZendeskAPI::DataResource do
  context "association" do
    subject { ZendeskAPI::TestResource.new(client, :id => 1) }
    let(:options) {{}}

    before(:each) do
      ZendeskAPI::TestResource.has :nil, options.merge(:class => ZendeskAPI::NilDataResource)
    end

    it "should try and find non-existent object" do
      stub_json_request(:get, %r{test_resources/1/nil}, json(:nil_data_resource => {}))

      expect(subject.nil).to be_instance_of(ZendeskAPI::NilDataResource)
    end

    context "inline => true" do
      let(:options) {{ :inline => true }}

      it "should not try and find non-existent object" do
        subject.nil
      end
    end
  end

  context "user" do
    context "with first order attributes" do
      subject { ZendeskAPI::TestResource.new(client) }
      before(:each) { subject.attributes[:priority] = "normal" }

      it "should be able to access underlying attributes" do
        expect(subject.priority).to eq("normal")
      end

      it "should be able to change underlying attributes" do
        expect { subject.priority = "urgent" }.to_not raise_error
      end

      it "should be able to iterate over underlying attributes" do
        expect do
          subject.map do |k, v|
            [k.to_sym, v]
          end
        end.to_not raise_error
      end
    end

    context "with second order attributes" do
      subject { ZendeskAPI::TestResource.new(client) }
      before(:each) { subject.priority = "normal" }

      it "should be able to change underlying attributes" do
        expect(subject.priority).to eq("normal")
      end

      it "should be able to change underlying attributes" do
        expect { subject.priority = "urgent" }.to_not raise_error
      end

      it "should be able to iterate over underlying attributes" do
        expect do
          subject.map do |k, v|
            [k.to_sym, v]
          end
        end.to_not raise_error
      end
    end
  end

  context "has" do
    before(:each) { ZendeskAPI::TestResource.has ZendeskAPI::TestResource }

    context "class methods" do
      subject { ZendeskAPI::TestResource }

      it "should define a method with the same name" do
        expect(subject.instance_methods.map(&:to_s)).to include("test_resource")
      end

      context "with explicit class name" do
        before(:all) { ZendeskAPI::TestResource.has :baz, :class => ZendeskAPI::TestResource }

        it "should define a method with the same name" do
          expect(subject.instance_methods.map(&:to_s)).to include("baz")
        end
      end
    end

    context "instance method" do
      context "with no side-loading" do
        subject { ZendeskAPI::TestResource.new(client, :id => 1, :test_resource_id => 1) }
        before(:each) { stub_json_request(:get, %r{test_resources/\d+}, json(:test_resource => {})) }

        it "should attempt to grab the resource from the host" do
          expect(subject.test_resource).to be_instance_of(ZendeskAPI::TestResource)
        end

        it "should pass the path on to the resource" do
          expect(subject.test_resource.path).to eq("test_resources")
        end

        context "with a client error" do
          before(:each) { stub_request(:get, %r{test_resources/\d+}).to_return(:status => 500) }

          it "should handle it properly" do
            expect { silence_logger{ expect(subject.test_resource).to be_nil } }.to_not raise_error
          end
        end

        context "with an explicit path set" do
          before(:each) do
            ZendeskAPI::TestResource.has ZendeskAPI::TestResource, :path => "blergh"
            stub_json_request(:get, %r{blergh/\d+}, json(:test_resource => {}))
          end

          it "should call the right path" do
            expect(subject.test_resource).to be_instance_of(ZendeskAPI::TestResource)
          end
        end
      end

      context "with side-loading of resource" do
        let(:test_resource) { { :message => "FOO_OBJ" } }
        subject { ZendeskAPI::TestResource.new(client, :test_resource => test_resource).test_resource }

        it "should load the correct instance" do
          expect(subject).to be_instance_of(ZendeskAPI::TestResource)
        end

        it "should load foo from the hash" do
          expect(subject.message).to eq("FOO_OBJ")
        end
      end

      context "with side-loading of id" do
        subject { ZendeskAPI::TestResource.new(client, :test_resource_id => 1) }
        before(:each) do
          stub_json_request(:get, %r{test_resources/1}, json("test_resource" => {}))
        end

        it "should find foo_id and load it from the api" do
          subject.test_resource
        end

        it "should handle nil response from find api" do
          expect(ZendeskAPI::TestResource).to receive(:find).twice.and_return(nil)
          expect(subject.test_resource).to be_nil
          subject.test_resource
        end
      end
    end
  end

  context "has_many" do
    before(:each) { ZendeskAPI::TestResource.has_many ZendeskAPI::TestResource }

    context "class methods" do
      subject { ZendeskAPI::TestResource }

      it "should define a method with the same name" do
        expect(subject.instance_methods.map(&:to_s)).to include("test_resources")
      end

      context "with explicit class name" do
        before(:each) { ZendeskAPI::TestResource.has_many :cats, :class => ZendeskAPI::TestResource }

        it "should define a method with the same name" do
          expect(subject.instance_methods.map(&:to_s)).to include("cats")
        end
      end
    end

    context "instance method" do
      context "with no side-loading" do
        subject { ZendeskAPI::TestResource.new(client, :id => 1) }

        it "should not attempt to grab the resource from the host" do
          expect(subject.test_resources).to be_instance_of(ZendeskAPI::Collection)
        end

        it "should pass the path on to the resource" do
          expect(subject.test_resources.path).to eq("test_resources/1/test_resources")
        end

        context "with an explicit path set" do
          before(:each) do
            ZendeskAPI::TestResource.has_many ZendeskAPI::TestResource, :path => "blargh"
          end

          it "should call the right path" do
            expect(subject.test_resources.path).to eq("test_resources/1/blargh")
          end
        end
      end

      context "with side-loading of resource" do
        let(:test_resources) { [{ :message => "FOO_OBJ" }] }
        subject { ZendeskAPI::TestResource.new(client, :test_resources => test_resources).test_resources.first }

        it "should properly create instance" do
          expect(subject.message).to eq("FOO_OBJ")
        end

        it "should map bars onto TestResource class" do
          expect(subject).to be_instance_of(ZendeskAPI::TestResource)
        end
      end

      context "with side-loading of id" do
        let(:test_resource_ids) { [1, 2, 3] }
        subject { ZendeskAPI::TestResource.new(client, :test_resource_ids => test_resource_ids) }

        it "should find foo_id and load it from the api" do
          expect(ZendeskAPI::TestResource).to receive(:find).with(client, kind_of(Hash)).exactly(test_resource_ids.length).times
          subject.test_resources
        end

        it "should handle nil response from find api" do
          expect(ZendeskAPI::TestResource).to receive(:find).with(client, kind_of(Hash)).exactly(test_resource_ids.length).times.and_return(nil)
          expect(subject.test_resources).to be_empty
          subject.test_resources # Test expectations
        end
      end
    end
  end
end


describe ZendeskAPI::Resource do
  context "initialize" do
    context "with :global as part of attributes" do
      it "should set @global_params" do
        resource = ZendeskAPI::TestResource.new(client, {global: {something: "hey"}})
        expect(resource.instance_variable_get(:@global_params)).to eq({something: "hey"})
      end
    end
  end

  context "#update" do
    context "class method" do
      let(:id) { 1 }
      subject { ZendeskAPI::TestResource }

      before(:each) do
        stub_json_request(:put, %r{test_resources/#{id}}).with(body: json({test_resource: {test: :hello}}))
      end

      it "should return instance of resource" do
        expect(subject.update(client, id: id, test: :hello)).to be_truthy
      end

      context "with global params" do
        before(:each) do
          stub_json_request(:put, %r{test_resources/#{id}}).with(body: json({test_resource: {test: :hello}, something: "something"}))
        end

        it "should return instance of resource" do
          expect(subject.update(client, id: id, test: :hello, global: {something: "something"})).to be_truthy
        end
      end

      context "with client error" do
        before(:each) do
          stub_request(:put, %r{test_resources/#{id}}).to_return(status: 500)
        end

        it "should handle it properly" do
          expect { silence_logger { expect(subject.update(client, id: id)).to be(false) } }.to_not raise_error
        end
      end
    end

    context "instance method" do
      subject(:resource) do
        ZendeskAPI::TestResource.new(client, id: 1)
      end

      it "is delegated to the attributes" do
        expect(resource.attributes).to receive(:update).and_call_original
        resource.update(subject: "Hello?")
      end

      it { is_expected.to respond_to(:update) }
    end
  end

  context "#destroy" do
    context "class method" do
      let(:id) { 1 }
      subject { ZendeskAPI::TestResource }

      before(:each) do
        stub_json_request(:delete, %r{test_resources/#{id}}).to_return(status: 204)
      end

      it "should return instance of resource" do
        expect(subject.destroy(client, id: id)).to be(true)
      end

      context "with client error" do
        before(:each) do
          stub_request(:delete, %r{test_resources/#{id}}).to_return(status: 500)
        end

        it "should handle it properly" do
          expect { silence_logger { expect(subject.destroy(client, id: id)).to be(false) } }.to_not raise_error
        end
      end
    end

    context "instance method" do
      subject { ZendeskAPI::TestResource.new(client, id: 1) }

      before(:each) do
        stub_request(:delete, %r{test_resources}).to_return(status: 204)
      end

      it "should return true and set destroyed" do
        expect(subject.destroy).to be(true)
        expect(subject.destroyed?).to be(true)
        expect(subject.destroy).to be(false)
      end

      context "with client error" do
        before(:each) do
          stub_request(:delete, %r{test_resources}).to_return(status: 500)
        end

        it "should return false and not set destroyed" do
          silence_logger { expect(subject.destroy).to be(false) }
          expect(subject.destroyed?).to be(false)
        end
      end
    end
  end

  context "#save!" do
    subject { ZendeskAPI::TestResource.new(client, id: 1) }

    before(:each) do
      stub_request(:put, %r{test_resources/1}).to_return(status: 422)
    end

    it "should raise if save fails" do
      expect { subject.save! }.to raise_error(ZendeskAPI::Error::RecordInvalid)
    end
  end

  context "#save" do
    let(:id) { 1 }
    let(:attr) { {param: "test"} }
    subject { ZendeskAPI::TestResource.new(client, attr.merge(id: id)) }

    before :each do
      stub_json_request(:put, %r{test_resources/#{id}}, json(test_resource: {param: "abc"}))
    end

    it "should not save if already destroyed" do
      expect(subject).to receive(:destroyed?).and_return(true)
      expect(subject.save).to be(false)
    end

    it "should not be a new record with an id" do
      expect(subject.new_record?).to be(false)
    end

    it "should put on save" do
      expect(subject.save).to be(true)
      expect(subject[:param]).to eq("abc")
    end

    context "with unused associations" do
      before do
        ZendeskAPI::TestResource.associations.clear
        ZendeskAPI::TestResource.has :child, class: ZendeskAPI::TestResource::TestChild
        ZendeskAPI::TestResource.has_many :children, class: ZendeskAPI::TestResource::TestChild
      end

      it "should not touch them" do
        expect(subject.save).to eq(true)
      end
    end

    context "with client error" do
      before :each do
        stub_request(:put, %r{test_resources/1}).to_return(status: 500)
      end

      it "should be properly handled" do
        expect { silence_logger { expect(subject.save).to be(false) } }.to_not raise_error
      end
    end

    context "new record" do
      subject { ZendeskAPI::TestResource.new(client, attr) }

      before :each do
        stub_json_request(:post, %r{test_resources}, json(test_resource: attr.merge(id: id)), status: 201)
      end

      it "should be true without an id" do
        expect(subject.new_record?).to be(true)
      end

      it "should be false after creating" do
        expect(subject.save).to be(true)
        expect(subject.new_record?).to be(false)
        expect(subject.id).to eq(id)
      end
    end

    context "with nested associations to save" do
      context "has" do
        before(:each) do
          ZendeskAPI::TestResource.associations.clear
          ZendeskAPI::TestResource.has :child, class: ZendeskAPI::TestResource::TestChild
          stub_json_request(:put, %r{test_resources})
          subject.child = {id: 2}
        end

        it "should call save on the association" do
          subject.child.foo = "bar"
          expect(subject.child).to receive(:save)

          subject.save

          expect(subject.instance_variable_get(:@child)).to be_nil
        end

        it "should not call save on the association if they are synced" do
          expect(subject.child).to_not receive(:save)

          subject.save

          expect(subject.instance_variable_get(:@child)).to be_nil
        end
      end

      context "has_many" do
        before(:each) do
          ZendeskAPI::TestResource.associations.clear
          ZendeskAPI::TestResource.has_many :children, class: ZendeskAPI::TestResource::TestChild

          stub_json_request(:put, %r{test_resources})
          stub_json_request(:get, %r{children}, json(test_children: []))
        end

        it "should reset children_ids on save" do
          subject.children = [2, 3]
          subject.children_ids = [1]
          subject.save
          expect(subject.children_ids).to eq([2, 3])
          expect(subject.instance_variable_get(:@children)).to be_nil
        end

        it "should not save the associated objects when there are no changes" do
          subject.children = [2]
          expect(subject.children.first).to_not receive(:save)
          subject.save
          expect(subject.instance_variable_get(:@children)).to be_nil
        end

        it "should save the associated objects when it is new" do
          subject.children = [{foo: "bar"}]
          expect(subject.children.first).to receive(:save)
          subject.save
          expect(subject.instance_variable_get(:@children)).to be_nil
        end

        it "should not save the associated objects when it is set via full hash" do
          subject.children = [{id: 1, foo: "bar"}]
          expect(subject.children.first).to_not receive(:save)
          subject.save
          expect(subject.instance_variable_get(:@children)).to be_nil
        end

        it "should save the associated objects when it is changes" do
          subject.children = [{id: 1}]
          subject.children.first.foo = "bar"
          expect(subject.children.first).to receive(:save)
          subject.save
          expect(subject.instance_variable_get(:@children)).to be_nil
        end
      end

      context "inline" do
        before(:each) do
          class ZendeskAPI::NilResource
            def to_param
              "TESTDATA"
            end
          end

          ZendeskAPI::TestResource.associations.clear
        end

        context "true" do
          before(:each) do
            ZendeskAPI::TestResource.has :nil, class: ZendeskAPI::NilResource, inline: true

            subject.nil = {abc: :def}
          end

          it "should save param data" do
            subject.save_associations

            expect(subject.attributes[:nil]).to eq("TESTDATA")
          end

          it "should not save param data when unchanged" do
            subject.nil.clear_changes
            subject.save_associations

            expect(subject.attributes[:nil]).to be_nil
          end
        end

        context "create" do
          before(:each) do
            ZendeskAPI::TestResource.has :nil, class: ZendeskAPI::NilResource, inline: :create
            subject.nil = {abc: :def}
          end

          context "with a new record" do
            before(:each) do
              subject.id = nil
              subject.save_associations
            end

            it "should save param data" do
              expect(subject.attributes[:nil]).to eq("TESTDATA")
            end
          end

          context "with a saved record" do
            before(:each) do
              subject.save_associations
            end

            it "should not save param data" do
              expect(subject.attributes[:nil]).to be_nil
            end
          end
        end
      end
    end
  end

  context "on any" do
    let(:method) { "test_any_method" }

    before(:each) do
      ZendeskAPI::TestResource.any method
    end

    context "class method" do
      subject { ZendeskAPI::TestResource }

      it "should create a method of the same name" do
        expect(subject.instance_methods.map(&:to_s)).to include(method)
      end
    end

    context "instance method" do
      subject { ZendeskAPI::TestResource.new(client, id: 1) }

      it "throws an argumenterror without a :verb" do
        expect { subject.send(method) }.to raise_error(ArgumentError)
      end

      context "with an array response" do
        before(:each) do
          stub_json_request(:put, %r{test_resources/1/#{method}}, json(test_resources: [{id: 1, method: method}]))
        end

        it "should return true" do
          expect(subject.send(method, verb: :put)).to be(true)
        end

        it "should update the attributes if they exist" do
          subject.send(method, verb: :put)
          expect(subject[:method]).to eq(method)
        end
      end

      context "with a resource response" do
        before(:each) do
          stub_json_request(:put, %r{test_resources/1/#{method}}, json(test_resource: {id: 1, method: method}))
        end

        it "should return true" do
          expect(subject.send(method, verb: :put)).to be(true)
        end

        it "should update the attributes if they exist" do
          subject.send(method, verb: :put)
          expect(subject[:method]).to eq(method)
        end
      end

      context "with client error" do
        before(:each) do
          stub_request(:put, %r{test_resources/1/#{method}}).to_return(status: 500)
        end

        it "doesn't raise without bang" do
          silence_logger { expect(subject.send(method.to_s, verb: :put)).to be(false) }
        end

        it "raises with bang" do
          expect { silence_logger { subject.send("#{method}!", verb: :put) } }.to raise_error(ZendeskAPI::Error::ClientError)
        end
      end
    end
  end

  %w[put post delete].each do |verb|
    context "on #{verb}" do
      let(:method) { "test_#{verb}_method" }
      before(:each) do
        ZendeskAPI::TestResource.send(verb, method)
      end

      context "class method" do
        subject { ZendeskAPI::TestResource }

        it "should create a method of the same name" do
          expect(subject.instance_methods.map(&:to_s)).to include(method)
        end
      end

      context "instance method" do
        subject { ZendeskAPI::TestResource.new(client, id: 1) }

        context "with an array response" do
          before(:each) do
            stub_json_request(verb.to_sym, %r{test_resources/1/#{method}}, json(test_resources: [{id: 1, method: method}]))
          end

          it "should return true" do
            expect(subject.send(method)).to be(true)
          end

          it "should update the attributes if they exist" do
            subject.send(method)
            expect(subject[:method]).to eq(method)
          end
        end

        context "with a resource response" do
          before(:each) do
            stub_json_request(verb.to_sym, %r{test_resources/1/#{method}}, json(test_resource: {id: 1, method: method}))
          end

          it "should return true" do
            expect(subject.send(method)).to be(true)
          end

          it "should update the attributes if they exist" do
            subject.send(method)
            expect(subject[:method]).to eq(method)
          end
        end

        context "with client error" do
          before(:each) do
            stub_request(verb.to_sym, %r{test_resources/1/#{method}}).to_return(status: 500)
          end

          it "doesn't raise without bang" do
            silence_logger { expect(subject.send(method.to_s)).to be(false) }
          end

          it "raises with bang" do
            expect { silence_logger { subject.send("#{method}!") } }.to raise_error(ZendeskAPI::Error::ClientError)
          end
        end
      end
    end
  end

  context "#inspect" do
    it "should display nicely" do
      expected_user_representation = if RUBY_VERSION >= "3.4"
        "#<ZendeskAPI::User {\"foo\" => :bar}>"
      else
        "#<ZendeskAPI::User {\"foo\"=>:bar}>"
      end
      expect(ZendeskAPI::User.new(client, foo: :bar).inspect).to eq(expected_user_representation)
    end
  end

  context "#to_json" do
    subject { ZendeskAPI::TestResource.new(client, id: 1) }

    it "should call #to_json on @attributes" do
      expect(subject.attributes).to receive(:to_json)
      subject.to_json
    end
  end

  context "#==" do
    it "is same when id is same" do
      expect(ZendeskAPI::TestResource.new(client, :id => 1, "bar" => "baz")).to eq(ZendeskAPI::TestResource.new(client, :id => 1, "foo" => "bar"))
    end

    it "is same when object_id is same" do
      object = ZendeskAPI::TestResource.new(client, "bar" => "baz")
      expect(object).to eq(object)
    end

    it "is different when both have no id" do
      expect(ZendeskAPI::TestResource.new(client)).to_not eq(ZendeskAPI::TestResource.new(client))
    end

    it "is different when id is different" do
      expect(ZendeskAPI::TestResource.new(client, id: 2)).to_not eq(ZendeskAPI::TestResource.new(client, id: 1))
    end

    it "is same when class is Data" do
      expect(ZendeskAPI::TestResource.new(client, id: 2)).to eq(ZendeskAPI::TestResource::TestChild.new(client, id: 2))
    end

    it "is same when class is Integer" do
      expect(ZendeskAPI::TestResource.new(client, id: 2)).to eq(2)
    end

    it "is different when class is Integer" do
      expect(ZendeskAPI::TestResource.new(client, id: 2)).to_not eq(3)
    end

    it "is different when other is no resource" do
      expect(ZendeskAPI::TestResource.new(client, id: 2)).to_not eq(nil)
    end

    it "warns about weird comparissons" do
      object = ZendeskAPI::TestResource.new(client, id: 2)
      expect(object).to receive(:warn)
      expect(object).to_not eq("xxx")
    end
  end

  context "SingularTestResource" do
    context "#find" do
      before do
        stub_json_request(:get, %r{/singular_test_resource})
      end

      it "should not require an id" do
        expect do
          ZendeskAPI::SingularTestResource.find(client)
        end.to_not raise_error
      end
    end

    context "#update" do
      before do
        stub_json_request(:put, %r{/singular_test_resource})
      end

      it "should always PUT" do
        ZendeskAPI::SingularTestResource.update(client, test: :test)
      end
    end
  end

  context "Ticket#assignee" do
    subject { ZendeskAPI::Ticket.new(client, id: 1, assignee_id: nil) }

    it "should not try and make a request" do
      expect(subject.assignee).to be_nil
    end
  end

  context "#new" do
    it "builds with hash" do
      object = ZendeskAPI::TestResource.new(client, {})
      expect(object.attributes).to eq({})
    end

    it "fails to build with nil (e.g. empty response from server)" do
      expect {
        ZendeskAPI::TestResource.new(client, nil)
      }.to raise_error(/Expected a Hash/i)
    end
  end

  context "#create_or_update!" do
    let(:params) { {email: "hello@example.local", test: :hello} }

    subject { ZendeskAPI::CreateOrUpdateTestResource }

    before :each do
      stub_json_request(:post, %r{create_or_update_test_resources/create_or_update}, json(create_or_update_test_resource: {param: "abc"}))
    end

    it "should return instance of resource" do
      expect(subject.create_or_update!(client, params)).to be_truthy
    end

    context "with client error" do
      before(:each) do
        stub_request(:post, %r{create_or_update_test_resources/create_or_update}).to_return(status: 500)
      end

      it "should raise" do
        expect { subject.create_or_update!(client, params) }.to raise_error(ZendeskAPI::Error::ClientError)
      end
    end
  end
end

require 'core/spec_helper'

describe ZendeskAPI::Collection do
  subject do
    ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource)
  end

  context "initialization" do
    it "should set the resource class" do
      expect(subject.instance_variable_get(:@resource_class)).to eq(ZendeskAPI::TestResource)
    end

    it "should initially be empty" do
      expect(subject.instance_variable_defined?(:@resources)).to be(false)
    end
  end

  context "with array option passed in" do
    subject { ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource, :ids => [1, 2, 3, 4]) }

    it "should join array with commas" do
      expect(subject.instance_variable_get(:@options)[:ids]).to eq("1,2,3,4")
    end
  end

  context "deferral" do
    it "should defer #create_many! to the resource class" do
      collection = ZendeskAPI::Collection.new(client, ZendeskAPI::BulkTestResource)
      stub_json_request(:post, %r{bulk_test_resources/create_many$}, json(:job_status => {}))
      collection.create_many!([{ :name => 'Mick' }, { :name => 'Steven' }])
      assert_requested(:post, %r{bulk_test_resources/create_many$},
        :body => {
          :bulk_test_resources => [{ :name => 'Mick' }, { :name => 'Steven' }]
        }
      )
    end

    it "should defer #destroy_many! to the resource class" do
      collection = ZendeskAPI::Collection.new(client, ZendeskAPI::BulkTestResource)
      stub_json_request(:delete, %r{bulk_test_resources/destroy_many\?}, json(:job_status => {}))
      collection.destroy_many!([1, 2, 3])
      assert_requested(:delete, %r{bulk_test_resources/destroy_many\?ids=1,2,3$})
    end

    it "should defer #update_many! to the resource class" do
      collection = ZendeskAPI::Collection.new(client, ZendeskAPI::BulkTestResource)
      stub_json_request(:put, %r{bulk_test_resources/update_many\?}, json(:job_status => {}))
      collection.update_many!([1, 2, 3], { :name => 'Mick' })
      assert_requested(:put, %r{bulk_test_resources/update_many\?ids=1,2,3$})
    end

    it "should defer #create to the resource class" do
      stub_json_request(:post, %r{test_resources$}, json(:test_resource => {}))
      subject.create
    end

    it "should defer #find to the resource class" do
      stub_json_request(:get, %r{test_resources/1$}, json(:test_resource => {}))
      subject.find(:id => 1)
    end

    it "should defer #destroy to the resource class" do
      stub_json_request(:delete, %r{test_resources/1$}, json(:test_resource => {}))
      subject.destroy(:id => 1)
    end

    it "should defer #update to the resource class" do
      stub_json_request(:put, %r{test_resources/1$}, json(:test_resource => {}))
      subject.update(:id => 1)
    end

    context "when class doesn't have method" do
      subject do
        ZendeskAPI::Collection.new(client, ZendeskAPI::NilDataResource)
      end

      it "should raise NoMethodError" do
        expect { subject.create }.to raise_error(NoMethodError)
      end

      it "should raise NoMethodError" do
        expect { subject.create! }.to raise_error(NoMethodError)
      end
    end

    context "with a class with a parent" do
      let(:association) do
        ZendeskAPI::Association.new(:class => ZendeskAPI::TestResource::TestChild,
          :parent => ZendeskAPI::TestResource.new(client, :id => 1), :name => :children)
      end

      subject do
        ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource::TestChild,
          :association => association)
      end

      before(:each) do
        stub_json_request(:any, %r{/test_resources/\d+/child}, json("test_child" => {}))
      end

      it "should defer #create to the resource class with the parent id" do
        subject.create
      end

      it "should defer #destroy the resource class with the parent id" do
        subject.destroy(:id => 1)
      end

      it "should defer #find to the resource class with the parent id" do
        subject.find(:id => 1)
      end

      it "should defer #update to the resource class with the parent id" do
        subject.update(:id => 1)
      end

      context "on object push" do
        before(:each) do
          stub_json_request(:get, %r{test_resources/\d+/children}, json(:test_children => []))
          subject << { :id => 1 }
        end

        it "should pass association" do
          expect(subject.last.association).to eq(association)
        end

        it "should #build a resource and add it" do
          resource = subject.build
          expect(subject).to include(resource)
          expect(resource.association).to eq(subject.association)
        end

        it "should #build! a resource and add it" do
          resource = subject.build!
          expect(subject).to include(resource)
          expect(resource.association).to eq(subject.association)
        end
      end
    end
  end

  context "pagination with data" do
    before(:each) do
      stub_json_request(:get, %r{test_resources}, json(
        :test_resources => [{ :id => 1 }]
      ))
      subject.fetch(true)
    end

    context "on #page" do
      context "with nil" do
        before(:each) { subject.page(nil) }

        it "should not empty the cache" do
          expect(subject.instance_variable_get(:@resources)).to_not be_empty
        end
      end

      context "with a number" do
        before(:each) { subject.page(3) }

        it "should empty the cache" do
          expect(subject.instance_variable_get(:@resources)).to be_nil
        end
      end
    end

    context "on #per_page" do
      context "with nil" do
        before(:each) { subject.per_page(nil) }

        it "should not empty the cache" do
          expect(subject.instance_variable_get(:@resources)).to_not be_empty
        end
      end

      context "with a number" do
        before(:each) { subject.per_page(20) }

        it "should empty the cache" do
          expect(subject.instance_variable_get(:@resources)).to be_nil
        end
      end
    end
  end

  context "pagination with no options and no data" do
    it "should return an empty array on #next" do
      expect(subject.next).to be_empty
    end

    it "should return an empty array on #prev" do
      expect(subject.prev).to be_empty
    end
  end

  context "pagination with options and no data" do
    before(:each) { subject.per_page(5).page(2) }

    it "should set per_page option" do
      expect(subject.per_page(10)).to eq(subject)
      expect(subject.instance_variable_get(:@options)["per_page"]).to eq(10)
    end

    it "should set page option" do
      expect(subject.page(10)).to eq(subject)
      expect(subject.instance_variable_get(:@options)["page"]).to eq(10)
    end

    it "should increate page option" do
      expect(subject.next).to eq(3)
    end

    it "should decreate page option" do
      expect(subject.prev).to eq(1)
    end
  end

  context "all" do
    context "Faraday errors" do
      before(:each) do
        stub_json_request(:get, %r{test_resources$}, json(
          :test_resources => [{ :id => 1 }], :next_page => "/test_resources?page=2"
        ))

        stub_request(:get, %r{test_resources\?page=2}).to_return(:status => 500).then.to_return(
          :headers => { :content_type => "application/json" }, :status => 200,
          :body => json(:test_resources => [{ :id => 2 }], :next_page => "/test_resources?page=3"))

        stub_request(:get, %r{test_resources\?page=3}).to_return(:status => 404)
      end

      it "should retry from the same page" do
        class SearchError < Exception; end

        expect do |b|
          client.insert_callback do |env|
            if env[:status] == 500 && env[:url].request_uri =~ /test_resources/
              raise SearchError
            end
          end

          begin
            silence_logger { subject.all(&b) }
          rescue SearchError
            retry
          end
        end.to yield_successive_args(
          [ZendeskAPI::TestResource.new(client, :id => 1), 1],
          [ZendeskAPI::TestResource.new(client, :id => 2), 2]
        )
      end

      it "should retry from the same page!" do
        expect do |b|
          begin
            subject.all!(&b)
          rescue ZendeskAPI::Error::NetworkError
            retry
          rescue ZendeskAPI::Error::ClientError
          end
        end.to yield_successive_args(
          [ZendeskAPI::TestResource.new(client, :id => 1), 1],
          [ZendeskAPI::TestResource.new(client, :id => 2), 2]
        )
      end

      it "raises an ArgumentError without a block (all)" do
        expect do |b|
          subject.all
        end.to raise_error(ArgumentError)
      end

      it "raises an ArgumentError without a block (all!)" do
        expect do |b|
          subject.all!
        end.to raise_error(ArgumentError)
      end
    end

    context "requests with no next_page" do
      before(:each) do
        stub_json_request(:get, %r{test_resources$}, json(
          :test_resources => [{ :id => 1 }],
          :next_page => "/test_resources?page=2"
        ))

        stub_json_request(:get, %r{test_resources\?page=2}, json(
          :test_resources => [{ :id => 2 }]
        ))
      end

      it "should yield resource and page" do
        expect do |b|
          silence_logger { subject.all(&b) }
        end.to yield_successive_args(
          [ZendeskAPI::TestResource.new(client, :id => 1), 1],
          [ZendeskAPI::TestResource.new(client, :id => 2), 2]
        )
      end
    end

    context "incremental requests" do
      subject do
        ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource, :path => 'incremental/test_resources?start_time=0')
      end

      before(:each) do
        stub_json_request(:get, %r{incremental/test_resources\?start_time=0$}, json(
          :test_resources => [{ :id => 1 }],
          :next_page => "/incremental/test_resources?start_time=200"
        ))

        stub_json_request(:get, %r{incremental/test_resources\?start_time=200$}, json(
          :test_resources => [{ :id => 2 }],
          :next_page => "/incremental/test_resources?start_time=200"
        ))
      end

      it "should yield resource and page (and not infinitely loop)" do
        expect do |b|
          Timeout.timeout(5) do
            silence_logger { subject.all(&b) }
          end
        end.to yield_successive_args(
          [ZendeskAPI::TestResource.new(client, :id => 1), 1],
          [ZendeskAPI::TestResource.new(client, :id => 2), 1] # page defaults to 1
        )
      end
    end

    context "infinite loops" do
      before(:each) do
        stub_json_request(:get, %r{test_resources$}, json(
          :test_resources => [{ :id => 1 }],
          :next_page => "/test_resources?page=2"
        ))

        stub_json_request(:get, %r{/test_resources\?page=2$}, json(
          :test_resources => [{ :id => 2 }],
          :next_page => "/test_resources?page=2"
        ))
      end

      xit "should yield resource and page (and not infinitely loop)" do
        expect do |b|
          Timeout.timeout(5) do
            silence_logger { subject.all(&b) }
          end
        end.to yield_successive_args(
          [ZendeskAPI::TestResource.new(client, :id => 1), 1],
          [ZendeskAPI::TestResource.new(client, :id => 2), 2]
        )
      end
    end

    context "successful requests" do
      before(:each) do
        stub_json_request(:get, %r{test_resources$}, json(
          :test_resources => [{ :id => 1 }],
          :next_page => "/test_resources?page=2"
        ))

        stub_json_request(:get, %r{test_resources\?page=2}, json(
          :test_resources => [{ :id => 2 }],
          :next_page => "/test_resources?page=3"
        ))

        stub_request(:get, %r{test_resources\?page=3}).to_return(:status => 404)
      end

      it "should yield resource if arity == 1" do
        expect do |block|
          # Needed to make sure the arity == 1
          block.instance_eval do
            def to_proc
              @used = true

              probe = self
              callback = @callback
              Proc.new do |arg|
                probe.num_yields += 1
                probe.yielded_args << [arg]
                callback.call([arg])
                nil
              end
            end
          end

          silence_logger { subject.all(&block) }
        end.to yield_successive_args(
          [ZendeskAPI::TestResource.new(client, :id => 1)],
          [ZendeskAPI::TestResource.new(client, :id => 2)]
        )
      end

      it "should yield resource and page" do
        expect do |b|
          silence_logger { subject.all(&b) }
        end.to yield_successive_args(
          [ZendeskAPI::TestResource.new(client, :id => 1), 1],
          [ZendeskAPI::TestResource.new(client, :id => 2), 2]
        )
      end

      context "afterwards" do
        before(:each) do
          silence_logger { subject.all { |_| } }
        end

        it "should reset the collection" do
          expect(subject.first_page?).to be(true)
          expect(subject.fetch).to eq([ZendeskAPI::TestResource.new(client, :id => 1)])
        end
      end
    end
  end

  context "fetch" do
    context "grabbing the current page" do
      context "from next_page" do
        before(:each) do
          stub_json_request(:get, %r{test_resources}, json(
            :test_resources => [{ :id => 2 }],
            :next_page => "/test_resources?page=2"
          ))

          subject.fetch(true)
          @page = subject.instance_variable_get(:@options)["page"]
        end

        it "should set the page to 1" do
          expect(@page).to eq(1)
        end
      end

      context "from prev_page" do
        before(:each) do
          stub_json_request(:get, %r{test_resources}, json(
            :test_resources => [{ :id => 2 }],
            :previous_page => "/test_resources?page=1"
          ))

          subject.fetch(true)
          @page = subject.instance_variable_get(:@options)["page"]
        end

        it "should set the page to 2" do
          expect(@page).to eq(2)
        end
      end

      context "with nothing" do
        before(:each) do
          stub_json_request(:get, %r{test_resources}, json(:test_resources => [{ :id => 2 }]))
          subject.fetch(true)
          @page = subject.instance_variable_get(:@options)["page"]
        end

        it "should not set the page" do
          expect(@page).to be_nil
        end
      end
    end

    context "with client error" do
      before(:each) do
        stub_request(:get, %r{test_resources}).to_return(:status => 500)
      end

      it "should properly be handled" do
        silence_logger { expect(subject.fetch(true)).to be_empty }
      end
    end

    context "with an invalid model key expectation" do
      before(:each) do
        stub_json_request(:get, %r{test_resources}, json(
          :test_resource_stuff => [{ :id => 2 }],
          :next_page => "/test_resources?page=2"
        ))
      end

      it "should properly be handled" do
        expect(subject.fetch(true)).to be_empty
      end
    end

    context "with nil body" do
      before(:each) do
        stub_request(:get, %r{test_resources}).to_return(:status => 200)
      end

      it "should properly be handled" do
        silence_logger { expect(subject.fetch(true)).to be_empty }
      end
    end

    context "with unfetchable resource" do
      subject { ZendeskAPI::Collection.new(client, ZendeskAPI::NilResource) }

      it "should not call connection" do
        expect(client.connection).to_not receive(:get)
        expect(subject.fetch(true)).to be_empty
      end
    end
  end

  context "save" do
    let(:options) { { :abc => 1 } }
    before(:each) do
      stub_json_request(:get, %r{test_resources}, json(:test_resources => []))
      subject.clear_cache
    end

    context "with a hash" do
      let(:object) { double('ZendeskAPI::TestResource', :changes => [:xxx], :changed? => true, :destroyed? => false) }

      it "should call create with those options" do
        expect(ZendeskAPI::TestResource).to receive(:new).
          with(client, options.merge(:association => subject.association)).
          and_return(object)

        subject << options

        expect(object).to receive(:save)
        subject.save

        expect(subject).to include(object)
      end
    end

    context "with a new object" do
      let(:object) { ZendeskAPI::TestResource.new(client, options) }
      before(:each) do
        subject << object
      end

      it "should save object" do
        expect(object).to receive(:save)
        subject.save
      end

      it "should have object in collection" do
        expect(subject).to include(object)
      end
    end

    context "with everything else" do
      it "should pass to new, since this is how attachment handles it" do
        attachment = double(:changes => [:xxx], :changed? => true, :destroyed? => false)
        expect(ZendeskAPI::TestResource).to receive(:new).
          with(client, :id => "img.jpg", :association => instance_of(ZendeskAPI::Association)).
          and_return attachment

        subject << "img.jpg"

        expect(attachment).to receive(:save)
        subject.save
      end
    end

    context "with a destroyed object" do
      let(:object) { ZendeskAPI::TestResource.new(client, options) }

      before(:each) do
        subject << object
      end

      it "should not save object" do
        expect(object).to receive(:destroyed?).and_return(true)
        expect(object).to_not receive(:save)

        subject.save
      end

      it "should have object in collection" do
        expect(subject).to include(object)
      end
    end
  end

  context "without real data" do
    subject do
      ZendeskAPI::Collection.new(client, ZendeskAPI::User)
    end

    before(:each) do
      stub_json_request(:get, %r{users\?page=2}, json(
        :users => [{ :id => 2 }],
        :next_page => "/users?page=3&per_page=1",
        :previous_page => "/users?page=1&per_page=1"
      ))

      subject.per_page(1).page(2)
      subject.fetch(true)
    end

    context "pagination with no options" do
      before(:each) do
        stub_json_request(:get, %r{users\?page=(1|3)}, json(:users => [{ :id => 3 }]))

        subject.per_page(nil).page(nil)
      end

      it "should find the next page by calling fetch" do
        current = subject.to_a.dup
        nxt = subject.next

        expect(nxt.size).to eq(1)
        expect(nxt).to_not eq(current)
      end

      it "should find the prev page by calling fetch" do
        current = subject.to_a.dup
        prev = subject.prev

        expect(prev.size).to eq(1)
        expect(prev).to_not eq(current)
      end
    end

    context "pagination with options", :vcr do
      before(:each) { subject.per_page(1).page(2) }

      it "should increase page option and not call fetch" do
        expect(subject.next).to eq(3)
      end

      it "should decrease page option and not call fetch" do
        expect(subject.prev).to eq(1)
      end

      context "with page == 1" do
        before do
          subject.page(1)
          subject.clear_cache
          expect(subject).to_not receive(:fetch)
        end

        it "should do nothing on #prev" do
          expect(subject.prev).to eq([])
        end
      end
    end
  end

  context "side loading" do
    before(:each) do
      subject.include(:nil_resources)
    end

    context "singular id on resource" do
      before(:each) do
        ZendeskAPI::TestResource.has ZendeskAPI::NilResource

        stub_json_request(:get, %r{test_resources\?include=nil_resources}, json(
          :test_resources => [{ :id => 1, :nil_resource_id => 4 }],
          :nil_resources => [{ :id => 1, :name => :bye }, { :id => 4, :name => :hi }]
        ))

        subject.fetch(true)

        @resource = subject.detect { |res| res.id == 1 }
      end

      it "should side load nil_resources" do
        expect(@resource.nil_resource).to_not be_nil
      end

      it "should side load the correct nil_resource" do
        expect(@resource.nil_resource.name).to eq("hi")
      end
    end

    context "multiple resources" do
      before(:each) do
        ZendeskAPI::TestResource.has ZendeskAPI::NilResource

        stub_json_request(:get, %r{test_resources\?include=nil_resources}, json(
          :test_resources => [{ :id => 1, :nil_resource_id => 4 }, { :id => 2, :nil_resource_id => 1 }],
          :nil_resources => [{ :id => 1, :name => :bye }, { :id => 4, :name => :hi }]
        ))

        subject.fetch(true)
      end

      context "first resource" do
        before(:each) { @resource = subject.detect { |res| res.id == 1 } }

        it "should side load nil_resources" do
          expect(@resource.nil_resource).to_not be_nil
        end

        it "should side load the correct nil_resource" do
          expect(@resource.nil_resource.name).to eq("hi")
        end
      end

      context "second resource" do
        before(:each) { @resource = subject.detect { |res| res.id == 2 } }

        it "should side load nil_resources" do
          expect(@resource.nil_resource).to_not be_nil
        end

        it "should side load the correct nil_resource" do
          expect(@resource.nil_resource.name).to eq("bye")
        end
      end
    end

    context "plural ids on resource" do
      before(:each) do
        ZendeskAPI::TestResource.has_many ZendeskAPI::NilResource

        stub_json_request(:get, %r{test_resources\?include=nil_resources}, json(
          :test_resources => [{ :id => 1, :nil_resource_ids => [1, 4] }],
          :nil_resources => [{ :id => 1, :name => :hi }, { :id => 4, :name => :hello }, { :id => 5, :name => :goodbye }]
        ))

        subject.fetch(true)

        @resource = subject.detect { |res| res.id == 1 }
      end

      it "should side load nil_resources" do
        expect(@resource.nil_resources).to_not be_empty
      end

      it "should side load the correct nil_resources" do
        expect(@resource.nil_resources.map(&:name)).to eq(%w{hi hello})
      end
    end

    context "ids in side load" do
      before(:each) do
        ZendeskAPI::TestResource.has_many ZendeskAPI::NilResource

        stub_json_request(:get, %r{test_resources\?include=nil_resources}, json(
          :test_resources => [{ :id => 1 }],
          :nil_resources => [{ :id => 1, :test_resource_id => 2 }, { :id => 2, :test_resource_id => 1 }, { :id => 4, :test_resource_id => 1 }]
        ))

        subject.fetch(true)
        @resource = subject.detect { |res| res.id == 1 }
      end

      it "should side load nil_resources" do
        expect(@resource.nil_resources).to_not be_empty
      end

      it "should side load the correct nil_resources" do
        expect(@resource.nil_resources.map(&:id)).to eq([2, 4])
      end
    end

    context "id in side load" do
      before(:each) do
        ZendeskAPI::TestResource.has ZendeskAPI::NilResource

        stub_json_request(:get, %r{test_resources\?include=nil_resources}, json(
          :test_resources => [{ :id => 1 }],
          :nil_resources => [{ :id => 1, :test_resource_id => 2 }, { :id => 2, :test_resource_id => 1 }]
        ))

        subject.fetch(true)
        @resource = subject.detect { |res| res.id == 1 }
      end

      it "should side load nil_resources" do
        expect(@resource.nil_resource).to_not be_nil
      end

      it "should side load the correct nil_resources" do
        expect(@resource.nil_resource.id).to eq(2)
      end
    end

    context "with name as key" do
      before(:each) do
        ZendeskAPI::TestResource.has ZendeskAPI::NilResource, :include_key => :name

        stub_json_request(:get, %r{test_resources\?include=nil_resources}, json(
          :test_resources => [{ :id => 1, :nil_resource_id => 4 }],
          :nil_resources => [{ :name => 1 }, { :name => 4 }]
        ))

        subject.fetch(true)

        @resource = subject.detect { |res| res.id == 1 }
      end

      it "should side load nil_resources" do
        expect(@resource.nil_resource).to_not be_nil
      end

      it "should side load the correct nil_resource" do
        expect(@resource.nil_resource.name).to eq(4)
      end
    end

    context "sub-loading" do
      before(:each) do
        ZendeskAPI::TestResource.has ZendeskAPI::TestResource::TestChild
        ZendeskAPI::TestResource::TestChild.has ZendeskAPI::NilResource

        stub_json_request(:get, %r{test_resources\?include=nil_resources}, json(
          :test_resources => [{ :id => 1, :test_child => { :nil_resource_id => 4 } }],
          :nil_resources => [{ :id => 1 }, { :id => 4 }]
        ))

        subject.fetch(true)

        @resource = subject.detect { |res| res.id == 1 }.test_child
      end

      it "should side load nil_resources" do
        expect(@resource.nil_resource).to_not be_nil
      end

      it "should side load the correct nil_resource" do
        expect(@resource.nil_resource.id).to eq(4)
      end
    end
  end

  context "method missing" do
    before(:each) { allow(subject).to receive(:fetch).and_return([1, 2, nil, 3]) }

    context "with an class method on the resource class" do
      it "should pass methods to class if defined" do
        expect(subject.test).to eq("hi")
      end
    end

    it "should pass all methods not defined to resources" do
      expect(subject.compact).to eq([1, 2, 3])
    end

    it "should take a block" do
      expect(subject.map { |i| i.to_i + 1 }).to eq([2, 3, 1, 4])
    end

    it "should create a new collection if it isn't an array method" do
      expect(subject.recent).to be_instance_of(ZendeskAPI::Collection)
    end

    it "should pass the correct query_path to the new collection" do
      expect(subject.recent.instance_variable_get(:@collection_path).last).to eq(:recent)
    end
  end

  context "with a module (Search)" do
    subject { ZendeskAPI::Collection.new(client, ZendeskAPI::Search, :query => "hello") }

    before(:each) do
      stub_json_request(:get, %r{search\?query=hello}, json(:results => []))
    end

    it "should not blow up" do
      expect(subject.to_a).to eq([])
    end
  end

  context "with a module (SearchExport)" do
    subject { ZendeskAPI::Collection.new(client, ZendeskAPI::SearchExport, :query => "hello") }

    it "should not blow up" do
      stub_json_request(:get, %r{search/export\?query=hello}, json(:results => []))

      expect(subject.to_a).to eq([])
    end

    it "should not have more results" do
      stub_json_request(:get, %r{search/export\?query=hello}, json(:results => [], 
                                                                   :meta => {has_more: false}))

      subject.fetch
      response = subject.instance_variable_get(:@response).body
      expect(subject.has_more_results?(response)).to be(false)
    end

    it "should not have more pages data" do
      stub_json_request(:get, %r{search/export\?query=hello}, json(:results => [], 
                                                                   :meta => {has_more: false}, 
                                                                   :links => {:next => nil}))

      subject.fetch
      response = subject.instance_variable_get(:@response).body
      expect(subject.get_next_page_data(response)).to eq(response)
    end
  end

  context "with different path" do
    subject do
      ZendeskAPI::Collection.new(client, ZendeskAPI::TestResource, :collection_path => %w(test_resources active))
    end

    before(:each) do
      stub_json_request(:post, %r{test_resources/active})
    end

    context "deferral" do
      it "should defer #create to the resource class with proper path" do
        subject.create
      end
    end

    context "resources" do
      before(:each) do
        stub_json_request(:get, %r{test_resources/active},
          json(:test_resources => [{ :id => 1 }]))

        subject.fetch

        stub_json_request(:put, %r{test_resources/1})
      end

      it "should not save using the collection path" do
        resource = subject.first
        resource.save
      end
    end
  end
end

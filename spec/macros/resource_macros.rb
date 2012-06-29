module ResourceMacros
  def under(object, &blk)
    context "under a #{object.class.singular_resource_name}" do
      let(:default_options) { { "#{object.class.singular_resource_name}_id" => object.id } }
      instance_eval(&blk)
    end
  end

  def it_should_be_creatable(options={})
    context "creation" do
      use_vcr_cassette
      subject { described_class }

      before(:all) do
        VCR.use_cassette("#{described_class.to_s}_create") do
          @object = described_class.create(client, valid_attributes.merge(default_options))
        end
      end

      it "should have an id" do
        @object.should_not be_nil
        @object.send(options[:id] || :id).should_not be_nil
      end

      it "should be findable", :unless => metadata[:not_findable] do
        options = default_options
        options.merge!(:id => @object.id) unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
        described_class.find(client, options).should == @object
      end 

      after(:all) do
        VCR.use_cassette("#{described_class.to_s}_create_delete") do
          @object.destroy
        end
      end if metadata[:delete_after]
    end
  end

  def it_should_be_updatable(attribute, value = "TESTDATA")
    context "update" do
      use_vcr_cassette

      before(:all) do
        VCR.use_cassette("#{described_class.to_s}_update_create") do
          @object = described_class.create(client, valid_attributes.merge(default_options))
        end
      end

      before(:each) do
        @object.send("#{attribute}=", value)
      end

      it "should be savable" do
        @object.save.should be_true
      end

      context "after save" do
        before(:each) do
          @object.save
        end

        it "should keep attributes" do
          @object.send(attribute).should == value 
        end

        it "should be findable", :unless => metadata[:not_findable] do
          options = default_options
          options.merge!(:id => @object.id) unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
          described_class.find(client, options).should == @object
        end 
      end

      after(:all, :if => metadata[:delete_after]) do
        VCR.use_cassette("#{described_class.to_s}_update_delete") do
          @object.destroy
        end
      end
    end
  end

  def it_should_be_deletable(options = {})
    context "deletion" do
      use_vcr_cassette

      before(:all) do
        if options[:object]
          @object = options.delete(:object)
        else
          VCR.use_cassette("#{described_class.to_s}_delete_create") do
            @object = described_class.create(client, valid_attributes.merge(default_options))
          end
        end
      end

      it "should be destroyable" do
        @object.destroy.should be_true
        @object.destroyed?.should be_true

        if (!options.key?(:find) || options[:find]) && !example.metadata[:not_findable]
          opts = default_options
          opts.merge!(:id => @object.id) unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
          obj = silence_logger{ described_class.find(client, opts) }

          if options[:find]
            obj.send(options[:find].first).should == options[:find].last
          else
            obj.should be_nil
          end
        end
      end
    end
  end

  def it_should_be_readable(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    create = !!options.delete(:create)
    klass = args.first.is_a?(ZendeskAPI::DataResource) ? args.shift : client
    context_name = "read_#{klass.class}_#{args.join("_")}"

    context context_name do
      use_vcr_cassette

      before(:all) do
        VCR.use_cassette("#{described_class.to_s}_#{context_name}_create") do
          @object = described_class.create!(client, valid_attributes.merge(default_options))
        end
      end if create

      after(:all) do
        VCR.use_cassette("#{described_class.to_s}_#{context_name}_delete") do
          @object.destroy
        end
      end if create 

      it "should be findable" do
        result = klass
        args.each {|a| result = result.send(a, options) }

        if result.is_a?(ZendeskAPI::Collection)
          result.fetch(true).should_not be_empty
          result.fetch.should include(@object) if create
          object = result.first
        else
          result.should_not be_nil
          result.should == @object if create
          object = result
        end

        if described_class.respond_to?(:find) && !example.metadata[:not_findable]
          options = default_options
          options.merge!(:id => object.id) unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
          described_class.find(client, options).should_not be_nil 
        end
      end
    end
  end
end

module ResourceMacros
  def self.extended(klass)
    klass.send(:define_method, :default_options) {{}}
  end

  def under(object, &blk)
    context "under a #{object.class.singular_resource_name}" do
      let(:parent) { object }

      define_method(:default_options) do
        { "#{object.class.singular_resource_name}_id" => object.id }
      end

      instance_eval(&blk)
    end
  end

  def it_should_be_creatable(options={})
    context "creation", :vcr do
      subject { described_class }

      before(:all) do
        VCR.use_cassette("#{described_class.to_s}_create") do
          @object = described_class.create(client, valid_attributes.merge(default_options))
        end
      end

      it "should have an id" do
        expect(@object).to_not be_nil
        expect(@object.send(:id)).to_not be_nil
      end

      it "should be findable", :unless => metadata[:not_findable] do
        options = default_options
        options.merge!(:id => @object.id) unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
        expect(described_class.find(client, options)).to eq(@object)
      end

      after(:all) do
        VCR.use_cassette("#{described_class.to_s}_create_delete") do
          @object.destroy
        end
      end if metadata[:delete_after]
    end
  end

  def it_should_be_updatable(attribute, value = "TESTDATA")
    context "update", :vcr do
      before(:all) do
        VCR.use_cassette("#{described_class.to_s}_update_create") do
          @object = described_class.create(client, valid_attributes.merge(default_options))
        end
      end

      before(:each) do
        @object.send("#{attribute}=", value)
      end

      it "should be savable" do
        expect(@object.save).to be(true)
      end

      context "after save" do
        before(:each) do
          @object.save
        end

        it "should keep attributes" do
          expect(@object.send(attribute)).to eq(value )
        end

        it "should be findable", :unless => metadata[:not_findable] do
          options = default_options
          options.merge!(:id => @object.id) unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
          expect(described_class.find(client, options)).to eq(@object)
        end
      end

      after(:all) do
        VCR.use_cassette("#{described_class.to_s}_update_delete") do
          @object.destroy
        end
      end if metadata[:delete_after]
    end
  end

  def it_should_be_deletable(options = {})
    context "deletion", :vcr do
      before(:all) do
        if options[:object]
          @object = options.delete(:object)
        else
          VCR.use_cassette("#{described_class.to_s}_delete_create") do
            @object = described_class.create(client, valid_attributes.merge(default_options))
          end
        end
      end

      it "should be destroyable" do |example|
        expect(@object.destroy).to be(true)
        expect(@object.destroyed?).to be(true)

        if (!options.key?(:find) || options[:find]) && !example.metadata[:not_findable]
          opts = default_options
          opts.merge!(:id => @object.id) unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
          obj = described_class.find(client, opts)

          if options[:find]
            expect(obj.send(options[:find].first)).to eq(options[:find].last)
          else
            expect(obj).to be_nil
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

    context context_name, :vcr do
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

      it "should be findable" do |example|
        result = klass
        args.each {|a| result = result.send(a, options) }

        if result.is_a?(ZendeskAPI::Collection)
          expect(result.fetch(true)).to_not be_empty
          expect(result.fetch).to include(@object) if create
          object = result.first
        else
          expect(result).to_not be_nil
          expect(result).to eq(@object) if create
          object = result
        end

        if described_class.respond_to?(:find) && !example.metadata[:not_findable]
          options = default_options
          options.merge!(:id => object.id) unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
          expect(described_class.find(client, options)).to_not be_nil
        end
      end
    end
  end
end

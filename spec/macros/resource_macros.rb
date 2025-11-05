module ResourceMacros
  def self.extended(klass)
    klass.send(:define_method, :default_options) { {} }
  end

  def under(object, &blk)
    context "under a #{object.class.singular_resource_name}" do
      let(:parent) { object }

      define_method(:default_options) do
        {"#{object.class.singular_resource_name}_id" => object.id}
      end

      instance_eval(&blk)
    end
  end

  def it_should_be_creatable(options = {})
    context "creation", :vcr do
      subject { described_class }

      before(:all) do
        VCR.use_cassette("#{described_class}_create") do
          @creatable_object = described_class.create!(client, valid_attributes.merge(default_options))
        end
      end

      it "should have an id" do
        expect(@creatable_object).to_not be_nil
        expect(@creatable_object.send(:id)).to_not be_nil
      end

      it "should be findable", unless: metadata[:not_findable] do
        options = default_options
        options[:id] = @creatable_object.id unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
        expect(described_class.find(client, options)).to eq(@creatable_object)
      end

      if metadata[:delete_after]
        after(:all) do
          return unless @creatable_object&.id

          VCR.use_cassette("#{described_class}_create_delete") do
            @creatable_object.destroy
          end
        end
      end
    end
  end

  def it_should_be_updatable(attribute, value = "TESTDATA", extra = {})
    context "update", :vcr do
      before(:all) do
        VCR.use_cassette("#{described_class}_update_create") do
          @updatable_object = described_class.create!(client, valid_attributes.merge(default_options))
        end
      end

      before(:each) do
        @updatable_object.public_send("#{attribute}=", value)
        extra.each { |k, v| @updatable_object.public_send("#{k}=", v) }
      end

      it "should be savable" do
        expect(@updatable_object.save).to be(true), "Expected object to save, but it failed with errors: #{@updatable_object.errors&.full_messages&.join(", ")}"
      end

      context "after save" do
        before(:each) do
          @updatable_object.save
        end

        it "should keep attributes" do
          expect(@updatable_object.send(attribute)).to eq(value)
        end

        it "should be findable", unless: metadata[:not_findable] do
          options = default_options
          options[:id] = @updatable_object.id unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
          expect(described_class.find(client, options)).to eq(@updatable_object)
        end
      end

      if metadata[:delete_after]
        after(:all) do
          VCR.use_cassette("#{described_class}_update_delete") do
            @updatable_object&.destroy
          end
        end
      end
    end
  end

  def it_should_be_deletable(options = {})
    context "deletion", :vcr do
      before(:all) do
        if options[:object]
          @deletable_object = options.delete(:object)
        else
          VCR.use_cassette("#{described_class}_delete_create") do
            @deletable_object = described_class.create!(client, valid_attributes.merge(default_options))
          end
        end
      end

      it "should be destroyable" do |example|
        expect(@deletable_object.destroy).to be(true)
        expect(@deletable_object.destroyed?).to be(true)
        if (!options.key?(:find) || options[:find]) && !example.metadata[:not_findable]
          opts = default_options
          opts[:id] = @deletable_object.id unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
          obj = described_class.find(client, opts)

          if options[:find]
            expect(obj.send(options[:find].first)).to eq(options[:find].last)
          else
            options[:marked_for_deletion] ? (expect(obj.active?).to be_falsey) : (expect(obj).to be_nil)
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
      if create
        before(:all) do
          VCR.use_cassette("#{described_class}_#{context_name}_create") do
            @readable_object = described_class.create!(client, valid_attributes.merge(default_options))
          end
        end
      end

      if create
        after(:all) do
          VCR.use_cassette("#{described_class}_#{context_name}_delete") do
            @readable_object.destroy
          end
        end
      end

      it "should be findable" do |example|
        result = klass
        args.each { |a| result = result.send(a, options) }

        if result.is_a?(ZendeskAPI::Collection)
          if create
            object = nil

            result.all do |o|
              object = o if @readable_object == o
            end

            expect(object).to_not be_nil
          else
            expect(result.fetch(true)).to_not be_empty
            object = result.first
          end
        else
          expect(result).to_not be_nil
          expect(result).to eq(@readable_object) if create
          object = result
        end

        if described_class.respond_to?(:find) && !example.metadata[:not_findable]
          options = default_options
          options[:id] = object.id unless described_class.ancestors.include?(ZendeskAPI::SingularResource)
          expect(described_class.find(client, options)).to_not be_nil
        end
      end
    end
  end
end

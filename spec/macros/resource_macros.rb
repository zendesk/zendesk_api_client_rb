module ResourceMacros
  def it_should_be_creatable(attributes = {})
    context "creation" do
      use_vcr_cassette
      subject { described_class }

      before(:all) do
        VCR.use_cassette("#{described_class.to_s}_create") do
          @object = described_class.create(client, valid_attributes)
        end
      end

      it "should have an id" do
        @object.id.should_not be_nil
      end

      it "should be findable", :unless => metadata[:not_findable] do
        described_class.find(client, @object.id).should == @object
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
          @object = described_class.create(client, valid_attributes)
        end
      end

      before(:each) do
        @object.attributes[attribute] = value 
      end

      it "should be savable" do
        @object.save.should be_true
      end

      context "after save" do
        before(:each) do
          @object.save
        end

        it "should keep attributes" do
          @object.attributes[attribute].should == value 
        end

        it "should be findable", :unless => metadata[:not_findable] do
          described_class.find(client, @object.id).should == @object
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
        VCR.use_cassette("#{described_class.to_s}_delete_create") do
          @object = described_class.create(client, valid_attributes)
        end
      end

      it "should be destroyable" do
        @object.destroy.should be_true
        @object.destroyed?.should be_true

        if (!options.key?(:find) || options[:find]) && !example.metadata[:not_findable]
          obj = described_class.find(client, @object.id)

          begin
            obj.send(options[:find].first).should == options[:find].last
          rescue NameError
            obj.should be_nil
          end
        end
      end
    end
  end

  def it_should_be_readable(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    create = !!options.delete(:create)

    context "read" do
      use_vcr_cassette

      before(:all) do
        VCR.use_cassette("#{described_class.to_s}_read_create") do
          @object = described_class.create(client, valid_attributes)
        end
      end if create 

      after(:all) do
        VCR.use_cassette("#{described_class.to_s}_read_delete") do
          @object.destroy
        end
      end if create 

      it "should be findable" do
        result = args.first.is_a?(Zendesk::DataResource) ? args.shift : client
        args.each {|a| result = result.send(a, options)}
        result.fetch(true).should_not be_empty

        if described_class.respond_to?(:find) && !example.metadata[:not_findable]
          described_class.find(client, result.first.id).should_not be_nil 
        end
      end

      it "should be readable", :if => create && !metadata[:not_findable] do
        described_class.find(client, @object.id).should == @object
      end
    end
  end
end

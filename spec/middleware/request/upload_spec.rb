require 'spec_helper'
require 'tempfile'

describe ZendeskAPI::Middleware::Request::Upload do
  subject { ZendeskAPI::Middleware::Request::Upload.new(lambda {|env| env}) }
  let(:filename) { File.join(File.dirname(__FILE__), "test.jpg") }

  it "should handle no body" do
    subject.call({}).should == {}
  end

  it "should handle body with no file" do
    subject.call(:body => {})[:body].should == {} 
  end

  it "should handle invalid types" do
    subject.call(:body => { :file => :invalid })[:body].should == {}
  end

  context "with file string" do
    before(:each) do
      @env = subject.call(:body => { :file => filename })
    end

    it "should convert file string to UploadIO" do
      @env[:body][:uploaded_data].should be_instance_of(Faraday::UploadIO)
    end

    it "should remove file string" do
      @env[:body][:file].should be_nil
    end

    it "should add filename if none exist" do
      @env[:body][:filename].should == "test.jpg"
    end

    context "with filename" do
      before(:each) do
        @env = subject.call(:body => { :file => filename, :filename => "test" })
      end

      it "should not change filename" do
        @env[:body][:filename].should_not == "test.jpg"
      end
    end
  end

  begin
    require 'action_dispatch'
  rescue LoadError
    warn "Could not load ActionDispatch; not running ActionDispatch::Http::UploadedFile tests"
  end

  if defined?(ActionDispatch)
    class String
      def encoding_aware?; false; end
    end

    context "with an ActionDispatch::Http::UploadedFile" do
      before(:each) do
        @upload = ActionDispatch::Http::UploadedFile.new(:filename => "hello", :tempfile => Tempfile.new(File.basename(filename)))
        @env = subject.call(:body => { :file => @upload })
      end

      it "should convert file string to UploadIO" do
        @env[:body][:uploaded_data].should be_instance_of(Faraday::UploadIO)
      end

      it "should remove file string" do
        @env[:body][:file].should be_nil
      end

      it "should add filename if none exist" do
        @env[:body][:filename].should == "hello"
      end
    end
  end

  context "with a Tempfile" do
    before(:each) do
      @tempfile = Tempfile.new(File.basename(filename))
      @env = subject.call(:body => { :file => @tempfile })
    end

    it "should convert file string to UploadIO" do
      @env[:body][:uploaded_data].should be_instance_of(Faraday::UploadIO)
    end

    it "should remove file string" do
      @env[:body][:file].should be_nil
    end

    it "should add filename if none exist" do
      @env[:body][:filename].should == File.basename(@tempfile.path)
    end
  end

  context "with file instance" do
    context "top-level" do
      before(:each) do
        @env = subject.call(:body => { :file => File.new(filename) })
      end

      it "should convert file string to UploadIO" do
        @env[:body][:uploaded_data].should be_instance_of(Faraday::UploadIO)
      end

      it "should remove file string" do
        @env[:body][:file].should be_nil
      end

      it "should add filename if none exist" do
        @env[:body][:filename].should == "test.jpg"
      end

      context "with filename" do
        before(:each) do
          @env = subject.call(:body => { :file => File.new(filename), :filename => "test" })
        end

        it "should not change filename" do
          @env[:body][:filename].should_not == "test.jpg"
        end
      end
    end

    context "underneath a key" do
      context "only a file" do
        before(:each) do
          @env = subject.call(:body => { :user => { :photo => File.new(filename) } })
        end

        it "should convert file string to UploadIO" do
          @env[:body][:user][:photo][:uploaded_data].should be_instance_of(Faraday::UploadIO)
        end

        it "should add filename if none exist" do
          @env[:body][:user][:photo][:filename].should == "test.jpg"
        end
      end

      context "with filename" do
        before(:each) do
          @env = subject.call(:body => { :user => { :photo => { :file => File.new(filename), :filename => "test" } } })
        end

        it "should convert file string to UploadIO" do
          @env[:body][:user][:photo][:uploaded_data].should be_instance_of(Faraday::UploadIO)
        end

        it "should not change filename" do
          @env[:body][:user][:photo][:filename].should_not == "test.jpg"
        end
      end
    end
  end
end

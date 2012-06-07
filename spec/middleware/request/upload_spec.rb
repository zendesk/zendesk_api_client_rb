require 'spec_helper'

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

  context "with file instance" do
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
end

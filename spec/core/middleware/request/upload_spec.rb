require 'core/spec_helper'
require 'tempfile'
require 'action_dispatch'

describe ZendeskAPI::Middleware::Request::Upload do
  subject { ZendeskAPI::Middleware::Request::Upload.new(lambda {|env| env}) }
  let(:filename) { File.join(File.dirname(__FILE__), "test.jpg") }

  it "should handle no body" do
    expect(subject.call({})).to eq({})
  end

  it "should handle body with no file" do
    expect(subject.call(:body => {})[:body]).to eq({})
  end

  it "should handle invalid types" do
    expect(subject.call(:body => { :file => :invalid })[:body]).to eq({})
  end

  context "with file string" do
    before(:each) do
      @env = subject.call(:body => { :file => filename })
    end

    it "should convert file string to UploadIO" do
      expect(@env[:body][:uploaded_data]).to be_instance_of(Faraday::UploadIO)
    end

    it "should remove file string" do
      expect(@env[:body][:file]).to be_nil
    end

    it "should add filename if none exist" do
      expect(@env[:body][:filename]).to eq("test.jpg")
    end

    context "with filename" do
      before(:each) do
        @env = subject.call(:body => { :file => filename, :filename => "test" })
      end

      it "should not change filename" do
        expect(@env[:body][:filename]).to_not eq("test.jpg")
      end
    end
  end

  context "with an ActionDispatch::Http::UploadedFile" do
    before(:each) do
      @upload = ActionDispatch::Http::UploadedFile.new(:filename => "hello.jpg", :tempfile => Tempfile.new(['hello', '.jpg']))
      @env = subject.call(:body => { :file => @upload })
    end

    it "should convert file string to UploadIO" do
      expect(@env[:body][:uploaded_data]).to be_instance_of(Faraday::UploadIO)
    end

    it "should remove file string" do
      expect(@env[:body][:file]).to be_nil
    end

    it "should add filename if none exist" do
      expect(@env[:body][:filename]).to eq("hello.jpg")
    end

    it "should use the content type of the tempfile" do
      expect(@env[:body][:uploaded_data].content_type).to eq("image/jpeg")
    end

    context "when path does not resolve a mime_type" do
      it "should pass correct filename to Faraday::UploadIO" do
        expect(@env[:body][:filename]).to eq("hello.jpg")
        expect(@env[:body][:uploaded_data].original_filename).to eq(@env[:body][:filename])
      end

      it "should use the content_type of ActionDispatch::Http::UploadedFile " do
        @upload.content_type = 'application/random'

        env = subject.call(:body => { :file => @upload })
        expect(env[:body][:uploaded_data].content_type).to eq('application/random')
      end
    end
  end

  context "with a Tempfile" do
    before(:each) do
      @tempfile = Tempfile.new(File.basename(filename))
      @env = subject.call(:body => { :file => @tempfile })
    end

    it "should convert file string to UploadIO" do
      expect(@env[:body][:uploaded_data]).to be_instance_of(Faraday::UploadIO)
    end

    it "should remove file string" do
      expect(@env[:body][:file]).to be_nil
    end

    it "should add filename if none exist" do
      expect(@env[:body][:filename]).to eq(File.basename(@tempfile.path))
    end
  end

  context "with file instance" do
    context "top-level" do
      before(:each) do
        @env = subject.call(:body => { :file => File.new(filename) })
      end

      it "should convert file string to UploadIO" do
        expect(@env[:body][:uploaded_data]).to be_instance_of(Faraday::UploadIO)
      end

      it "should remove file string" do
        expect(@env[:body][:file]).to be_nil
      end

      it "should add filename if none exist" do
        expect(@env[:body][:filename]).to eq("test.jpg")
      end

      context "with filename" do
        before(:each) do
          @env = subject.call(:body => { :file => File.new(filename), :filename => "test" })
        end

        it "should not change filename" do
          expect(@env[:body][:filename]).to_not eq("test.jpg")
        end
      end
    end

    context "underneath a key" do
      context "only a file" do
        before(:each) do
          @env = subject.call(:body => { :user => { :photo => File.new(filename) } })
        end

        it "should convert file string to UploadIO" do
          expect(@env[:body][:user][:photo][:uploaded_data]).to be_instance_of(Faraday::UploadIO)
        end

        it "should add filename if none exist" do
          expect(@env[:body][:user][:photo][:filename]).to eq("test.jpg")
        end
      end

      context "with filename" do
        before(:each) do
          @env = subject.call(:body => { :user => { :photo => { :file => File.new(filename), :filename => "test" } } })
        end

        it "should convert file string to UploadIO" do
          expect(@env[:body][:user][:photo][:uploaded_data]).to be_instance_of(Faraday::UploadIO)
        end

        it "should not change filename" do
          expect(@env[:body][:user][:photo][:filename]).to_not eq("test.jpg")
        end
      end
    end
  end
end

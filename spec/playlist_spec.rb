require 'spec_helper'

describe ZendeskAPI::Playlist do
  subject { ZendeskAPI::Playlist }

  before(:each) do
    stub_request(:get, %r{views/\d+/play}).to_return(:status => 302, :body => "You are being redirected...")
  end

  it "should begin playing the playlist on initialization" do
    subject.new(client, 1)
  end

  context "#next" do
    subject { ZendeskAPI::Playlist.new(client, 1) }

    before(:each) do
      stub_json_request(:get, %r{play/next}, json("ticket" => {}))
    end

    it "should return ticket" do
      subject.next.should be_instance_of(ZendeskAPI::Ticket)
    end

    context "with client error", :silence_logger do
      before(:each) do
        stub_request(:get, %r{play/next}).to_return(:status => 500)
      end

      it "should be properly handled" do
        expect { subject.next.should be_nil }.to_not raise_error
      end
    end

    context "with end of playlist" do
      before(:each) do
        stub_request(:get, %r{play/next}).to_return(:status => 204)
      end

      it "should be properly handled" do
        subject.next.should be_nil
        subject.destroyed?.should be_true
      end
    end
  end

  context "#destroy" do
    subject { ZendeskAPI::Playlist.new(client, 1) }

    before(:each) do
      stub_request(:delete, %r{play}).to_return(:status => 204)
    end

    it "should be destroyed" do
      subject.destroy.should be_true
      subject.destroyed?.should be_true
    end

    context "with client error", :silence_logger do
      before(:each) do
        stub_request(:delete, %r{play}).to_return(:status => 500)
      end

      it "should be properly handled" do
        expect { subject.destroy.should be_false }.to_not raise_error
      end
    end
  end

  context "initialization" do
    context "with client error", :silence_logger do
      before(:each) do
        stub_request(:get, %r{views/\d+/play}).to_return(:status => 500).to_return(:status => 302)
        stub_request(:get, %r{play/next}).to_return(:body => json)
      end

      it "should be able to be created" do
        new_playlist = subject.new(client, 1)
        new_playlist.should_not be_nil
      end

      it "should retry initialization on #next" do
        new_playlist = subject.new(client, 1)
        new_playlist.should_receive(:init_playlist).and_return(:true)
        new_playlist.next
      end

      it "should retry initialization on #each" do
        new_playlist = subject.new(client, 1)
        new_playlist.should_receive(:next).and_return(Object.new, nil)
        new_playlist.each {|arg| :block }
      end
    end
  end
end

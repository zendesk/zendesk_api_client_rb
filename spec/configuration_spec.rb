require 'spec_helper.rb'

describe ZendeskAPI::Configuration do
  subject { ZendeskAPI::Configuration.new }

  it "should properly merge options" do
    url = "test.host"
    subject.url = url
    subject.options[:url].should == url
  end

  it "should set accept header properly" do
    subject.options[:headers][:accept].should == 'application/json'
  end

  it "should set user agent header properly" do
    subject.options[:headers][:user_agent].should =~ /ZendeskAPI API/
  end

  it "should merge options with client_options" do
    subject.client_options = {:ssl => false}
    subject.options[:ssl].should == false
  end
end

require 'spec_helper.rb'

describe Zendesk::Configuration do
  subject { Zendesk::Configuration.new }

  it "should properly merge options" do
    url = "test.host"
    subject.url = url
    subject.options[:url].should == url
  end

  it "should set accept header properly" do
    subject.options[:headers][:accept].should == 'application/json'
  end

  it "should set user agent header properly" do
    subject.options[:headers][:user_agent].should =~ /Zendesk API/
  end

  it "should merge options with client_options" do
    subject.client_options = {:ssl => false}
    subject.options[:ssl].should == false
  end

  context "when  work on behalf of other user" do
    #after(:all) { subject.options[:headers].delete(:x_on_behalf_of) }

    it "should merge options with client_options" do
      subject.client_options = { :x_on_behalf_of => 'sample@example.com' }
      subject.options[:headers][:x_on_behalf_of].should == 'sample@example.com'
    end
  end
end

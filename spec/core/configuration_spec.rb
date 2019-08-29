require 'core/spec_helper'

describe ZendeskAPI::Configuration do
  subject { ZendeskAPI::Configuration.new }

  it "should properly merge options" do
    url = "test.host"
    subject.url = url
    expect(subject.options[:url]).to eq(url)
  end

  it "should set accept header properly" do
    expect(subject.options[:headers][:accept]).to eq('application/json')
  end

  it "should set user agent header properly" do
    expect(subject.options[:headers][:user_agent]).to match(/ZendeskAPI Ruby/)
  end

  it "should set a default open_timeout" do
    expect(subject.options[:request][:open_timeout]).to eq(10)
  end

  it "should merge options with client_options" do
    subject.client_options = { :ssl => { :verify => false } }
    expect(subject.options[:ssl][:verify]).to eq(false)
  end
end

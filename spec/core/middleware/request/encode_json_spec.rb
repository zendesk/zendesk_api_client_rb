require 'core/spec_helper'

describe ZendeskAPI::Middleware::Request::EncodeJson do
  let(:app) do
    ZendeskAPI::Middleware::Request::EncodeJson.new(lambda {|x| x})
  end

  let(:response) { app.call({ :request_headers => {} }.merge(env)) }

  context 'with a nil body' do
    let(:env) {{ :body => nil }}

    it 'should not return json' do
      response[:body].should be_nil
    end
  end

  context 'with an empty body' do
    let(:env) {{ :body => '' }}

    it 'should not return json' do
      response[:body].should == ''
    end
  end

  context 'with a proper mime type' do
    context 'empty' do
      let(:env) {{ :body => { :a => :b } }}

      it 'encodes json' do
        response[:body].should == JSON.dump(:a => :b)
      end

      it 'sets the content type' do
        response[:request_headers]['Content-Type'].should == 'application/json'
      end
    end

    context 'application/json' do
      let(:env) {{
        :body => { :a => :b },
        :request_headers => {
          'Content-Type' => 'application/json'
        }
      }}

      it 'encodes json' do
        response[:body].should == JSON.dump(:a => :b)
      end

      it 'keeps the content type' do
        response[:request_headers]['Content-Type'].should == 'application/json'
      end
    end

    context 'application/json; encoding=utf-8' do
      let(:env) {{
        :body => { :a => :b },
        :request_headers => {
          'Content-Type' => 'application/json; encoding=utf-8'
        }
      }}

      it 'encodes json' do
        response[:body].should == JSON.dump(:a => :b)
      end

      it 'keeps the content type' do
        response[:request_headers]['Content-Type'].should == 'application/json; encoding=utf-8'
      end
    end
  end
end

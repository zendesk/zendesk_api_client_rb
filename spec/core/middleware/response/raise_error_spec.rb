require 'core/spec_helper'

describe ZendeskAPI::Middleware::Response::RaiseError do
  context "with a failed connection" do
    context "connection failed" do
      before(:each) do
        stub_request(:any, /.*/).to_raise(Faraday::ConnectionFailed)
      end

      it "should raise NetworkError" do
        expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::NetworkError)
      end
    end

    context "connection timeout" do
      before(:each) do
        stub_request(:any, /.*/).to_timeout
      end

      it "should raise NetworkError" do
        expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::NetworkError)
      end
    end
  end

  context "status errors" do
    let(:body) { "" }

    before(:each) do
      stub_request(:any, /.*/).to_return(:status => status, :body => body,
                                         :headers => { :content_type => "application/json" })
    end

    context "with status = 404" do
      let(:status) { 404 }

      it "should raise RecordNotFound when status is 404" do
        expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::RecordNotFound)
      end
    end

    context "with status in 400...600" do
      let(:status) { 500 }

      it "should raise NetworkError" do
        expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::NetworkError)
      end
    end

    context "with status in 1XX" do
      let(:status) { 100 }

      it "should raise NetworkError" do
        expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::NetworkError)
      end
    end

    context "with status = 304" do
      let(:status) { 304 }

      it "should not raise" do
        client.connection.get "/abcdef"
      end
    end

    context "with status in 3XX" do
      let(:status) { 302 }

      it "raises NetworkError with the right message" do
        expect { client.connection.get "/non_existent" }.to raise_error(
          ZendeskAPI::Error::NetworkError,
          "the server responded with status 302 for GET https://#{client.connection.host}/non_existent -- get https://#{client.connection.host}/non_existent"
        )
      end
    end

    context "with status = 422" do
      let(:status) { 422 }

      it "should raise RecordInvalid" do
        expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::RecordInvalid)
      end

      context "with a body" do
        let(:body) { JSON.dump(:details => "hello") }

        it "should return RecordInvalid with proper message" do
          client.connection.get "/non_existent"
        rescue ZendeskAPI::Error::RecordInvalid => e
          expect(e.errors).to eq("hello")
          expect(e.to_s).to eq("ZendeskAPI::Error::RecordInvalid: hello")
        else
          fail # didn't raise an error
        end

        {
          error: 'There was an error',
          errors: 'There were several errors'
        }.each do |key, message|
          context "with only an #{key} key" do
            let(:body) { JSON.dump(key => message) }

            it "should return RecordInvalid with proper message" do
              expect { client.connection.get "/non_existent" }.to raise_error do |error|
                expect(error).to be_a(ZendeskAPI::Error::RecordInvalid)
                expect(error.errors).to eq(message)
              end
            end
          end
        end
      end
    end

    context "with status = 413" do
      let(:status) { 413 }

      it "should raise RecordInvalid" do
        expect { client.connection.get "/non_existent" }.to raise_error(ZendeskAPI::Error::RecordInvalid)
      end

      context "with a body" do
        let(:body) { JSON.dump(:description => "big file is big", :message => "small file is small") }

        it "should return RecordInvalid with proper message" do
          client.connection.get "/non_existent"
        rescue ZendeskAPI::Error::RecordInvalid => e
          expect(e.errors).to eq("big file is big - small file is small")
          expect(e.to_s).to eq("ZendeskAPI::Error::RecordInvalid: big file is big - small file is small")
        else
          fail # didn't raise an error
        end

        {
          error: 'There was an error',
          errors: 'There were several errors'
        }.each do |key, message|
          context "with only an #{key} key" do
            let(:body) { JSON.dump(key => message) }

            it "should return RecordInvalid with proper message" do
              expect { client.connection.get "/non_existent" }.to raise_error do |error|
                expect(error).to be_a(ZendeskAPI::Error::RecordInvalid)
                expect(error.errors).to eq(message)
              end
            end
          end
        end
      end
    end

    context "with status = 200" do
      let(:status) { 200 }

      it "should not raise" do
        client.connection.get "/abcdef"
      end
    end
  end
end

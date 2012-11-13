module ZendeskAPI::Server
  module Helper
    def execute_request
      unless @method && client.connection.respond_to?(@method)
        @error = "The input you entered was invalid"
        return
      end

      begin
        response = client.connection.send(@method, @path) do |request|
          request.params = @url_params.inject({}) do |accum, h|
            accum.merge(h["name"] => h["value"])
          end

          if @method != :get && @json && !@json.empty?
            request.body = JSON.parse(@json)
          end

          set_request(request.to_env(client.connection))
        end
      rescue Faraday::Error::ConnectionFailed => e
        @error = "The connection failed"
      rescue Faraday::Error::ClientError => e
        set_response(e.response) if e.response
      rescue JSON::ParserError
        @error = "The JSON you attempted to send was invalid"
      rescue URI::InvalidURIError, ArgumentError
        @error = "Please enter a valid URL"
      else
        set_response(:body => response.body,
          :headers => response.env[:response_headers],
          :status => response.env[:status])
      end
    rescue ArgumentError
      # Raised by Client when allow_http is OFF
      @error = "Please enter a valid https URL"
    end

    def map_headers(headers)
      headers.map do |k,v|
        name = k.split("-").map(&:capitalize).join("-")
        "#{name}: #{v}"
      end.join("\n")
    end

    def set_request(request)
      @html_request = <<-END
HTTP/1.1 #{@method.to_s.upcase} #{request[:url]}
#{map_headers(request[:request_headers])}
      END

      request_headers = request[:request_headers].dup
      request_headers.delete("Authorization")

      @user_request_hash = { :url => request[:url].to_s, :request_headers => request_headers }

      if @method != :get && @json && !@json.empty?
        parsed_json = CodeRay.scan(@json, :json).span
        @html_request << "\n\n#{parsed_json}"
      end
    end

    def set_response(response)
      @html_response =<<-END
HTTP/1.1 #{response[:status]}
#{map_headers(response[:headers])}


#{CodeRay.scan(JSON.pretty_generate(response[:body]), :json).span}
      END

      @user_response_hash = { :status => response[:status], :headers => response[:headers], :body => response[:body] }
    end

    def client(params = params)
      @client ||= ZendeskAPI::Client.new do |c|
        params.each do |key, value|
          c.send("#{key}=", value)
        end

        c.allow_http = App.development?
      end
    end
  end
end

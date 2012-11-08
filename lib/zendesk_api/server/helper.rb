module ZendeskAPI::Server
  module Helper

    def execute
      begin
        response = client.connection.send(@method, @path) do |request|
          request.params = @url_params.inject({}) do |accum, h|
            accum.merge(h["name"] => h["value"])
          end

          if @method != :get && !@json.empty?
            request.body = JSON.parse(@json)
          end

          set_request(request.to_env(client.connection))
        end
      rescue Faraday::Error::ConnectionFailed => e
        @error = "The connection failed"
      rescue Faraday::Error::ClientError => e
        set_response(e.response) if e.response
      rescue JSON::ParserError => e
        @error = "The JSON you attempted to send was invalid"
      rescue URI::InvalidURIError => e
        @error = "Please enter a subdomain"
      else
        set_response(:body => response.body,
          :headers => response.env[:response_headers],
          :status => response.env[:status])
      end
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
    end

    def client(params = params)
      ZendeskAPI::Client.new do |c|
        params.each do |key, value|
          c.send("#{key}=", value)
        end
      end
    end
  end
end

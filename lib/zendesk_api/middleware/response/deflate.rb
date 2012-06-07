require 'faraday_middleware/response_middleware'

module ZendeskAPI
  module Middleware
    module Response
      # Faraday middleware to handle content-encoding = inflate
      class Deflate < FaradayMiddleware::ResponseMiddleware
        define_parser do |body|
          Zlib::Inflate.inflate(body)
        end

        def parse_response?(env)
          super && env[:response_headers]['content-encoding'] == "deflate"
        end
      end
    end
  end
end

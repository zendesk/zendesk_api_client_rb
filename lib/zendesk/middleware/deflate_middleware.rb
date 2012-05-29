require 'faraday_middleware/response_middleware'

module Zendesk
  module Response 
    # Faraday middleware to handle content-encoding = gzip
    class DeflateMiddleware < FaradayMiddleware::ResponseMiddleware
      define_parser do |body|
        Zlib::Inflate.inflate(body)
      end

      def parse_response?(env)
        super &&
          env[:response_headers]['content-encoding'] == "deflate"
      end
    end
  end
end

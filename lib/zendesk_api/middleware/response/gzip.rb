require 'faraday_middleware/response_middleware'
require 'zlib'
require 'stringio'

module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Response
      # Faraday middleware to handle content-encoding = gzip
      class Gzip < FaradayMiddleware::ResponseMiddleware
        define_parser do |body|
          Zlib::GzipReader.new(StringIO.new(body)).read
        end

        def parse_response?(env)
          super && env[:response_headers]['content-encoding'] == "gzip"
        end
      end
    end
  end
end

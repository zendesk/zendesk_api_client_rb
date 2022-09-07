require 'zlib'
require 'stringio'

module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Response
      # Faraday middleware to handle content-encoding = gzip
      class Gzip < Faraday::Middleware
        def on_complete(env)
          return if env[:response_headers]['content-encoding'] != "gzip"
          return if env[:body].force_encoding(Encoding::BINARY).strip.empty?

          env[:body] = Zlib::GzipReader.new(StringIO.new(env[:body])).read
        end
      end
    end
  end
end

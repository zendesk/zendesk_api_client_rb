module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Response
      # Faraday middleware to handle content-encoding = inflate
      # @private
      class Deflate < Faraday::Middleware
        def on_complete(env)
          return if env[:response_headers]["content-encoding"] != "deflate"
          return if env.body.strip.empty?

          env.body = Zlib::Inflate.inflate(env.body)
        end
      end
    end
  end
end

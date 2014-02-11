module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Response
      # Faraday middleware to handle content-encoding = inflate
      # @private
      class Deflate < Faraday::Response::Middleware
        def on_complete(env)
          if env.body.respond_to?(:to_str) && !env.body.strip.empty? && env[:response_headers]['content-encoding'] == "deflate"
            env.body = Zlib::Inflate.inflate(env.body)
          end
        end
      end
    end
  end
end

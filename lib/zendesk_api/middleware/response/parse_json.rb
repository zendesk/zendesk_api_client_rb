module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Response
      class ParseJson < Faraday::Middleware # Faraday::Response::Middleware
        CONTENT_TYPE = 'Content-Type'.freeze

        def on_complete(env)
          type = env[:response_headers][CONTENT_TYPE].to_s
          type = type.split(';', 2).first if type.index(';')

          return unless type == 'application/json'

          unless env[:body].strip.empty?
            env[:body] = JSON.parse(env[:body])
          end
        end
      end
    end
  end
end

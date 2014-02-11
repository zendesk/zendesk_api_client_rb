module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Response
      class ParseJson < Faraday::Response::Middleware
        CONTENT_TYPE = 'Content-Type'.freeze
        dependency 'json'

        def on_complete(env)
          type = env[:response_headers][CONTENT_TYPE].to_s
          type = type.split(';', 2).first if type.index(';')
          type

          if type == 'application/json' && env[:body].respond_to?(:to_str) && !env[:body].strip.empty?
            env[:body] = JSON.parse(env[:body])
          else
            env[:body] = nil
          end
        end
      end
    end
  end
end

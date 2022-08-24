module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Request
      class EncodeJson < Faraday::Middleware
        CONTENT_TYPE = 'Content-Type'.freeze
        MIME_TYPE = 'application/json'.freeze
        # dependency 'json' https://github.com/lostisland/faraday/blob/main/UPGRADING.md#the-dependency-method-in-middlewares-has-been-removed

        def call(env)
          type = env[:request_headers][CONTENT_TYPE].to_s
          type = type.split(';', 2).first if type.index(';')
          type

          if env[:body] && !(env[:body].respond_to?(:to_str) && env[:body].empty?) && (type.empty? || type == MIME_TYPE)
            env[:body] = JSON.dump(env[:body])
            env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE
          end

          @app.call(env)
        end
      end
    end
  end
end

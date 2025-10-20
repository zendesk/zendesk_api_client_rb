require "faraday/response"

module ZendeskAPI
  module Middleware
    module Response
      # @private
      class ZendeskRequestEvent < Faraday::Middleware
        def initialize(app, client)
          super(app)
          @client = client
        end

        def call(env)
          start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          @app.call(env).on_complete do |response_env|
            end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            duration = (end_time - start_time) * 1000.0
            instrumentation = @client.config.instrumentation
            if instrumentation
              instrumentation.instrument("zendesk.request",
                                         { duration: duration,
                                           endpoint: response_env[:url].path,
                                           method: response_env[:method],
                                           status: response_env[:status] })
              if response_env[:status] < 500
                instrumentation.instrument("zendesk.rate_limit",
                                           {
                                             endpoint: response_env[:url].path,
                                             status: response_env[:status],
                                             threshold: response_env[:response_headers] ? response_env[:response_headers][:x_rate_limit_remaining] : nil,
                                             limit: response_env[:response_headers] ? response_env[:response_headers][:x_rate_limit] : nil,
                                             reset: response_env[:response_headers] ? response_env[:response_headers][:x_rate_limit_reset] : nil
                                           })
              end
            end
          end
        end
      end
    end
  end
end

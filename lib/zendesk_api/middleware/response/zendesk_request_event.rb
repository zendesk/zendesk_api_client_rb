require "faraday/response"

module ZendeskAPI
  module Middleware
    module Response
      # @private
      class ZendeskRequestEvent < Faraday::Middleware
        def initialize(app, options = {})
          super(app)
          @instrumentation = options[:instrumentation]
          @logger = options[:logger]
        end

        def call(env)
          return @app.call(env) unless instrumentation

          start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          @app.call(env).on_complete do |response_env|
            stop_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

            begin
              instrument_request(response_env, start_time, stop_time)
              instrument_rate_limit(response_env)
            rescue => e
              logger&.debug("Instrumentation failed: #{e.message}")
            end
          end
        end

        private

        attr_reader :instrumentation, :logger

        def instrument_request(response_env, start_time, stop_time)
          duration_ms = (stop_time - start_time) * 1000.0

          payload = {
            duration: duration_ms,
            endpoint: response_env[:url]&.path,
            method: response_env[:method],
            status: response_env[:status]
          }

          instrumentation.instrument("zendesk.request", payload)
        end

        def instrument_rate_limit(response_env)
          status = response_env[:status]
          return unless status && status < 500

          headers = response_env[:response_headers]
          remaining, limit, reset = headers&.values_at(
            "X-Rate-Limit-Remaining",
            "X-Rate-Limit",
            "X-Rate-Limit-Reset"
          )
          return if [remaining, limit, reset].all?(&:nil?)

          payload = {
            endpoint: response_env[:url]&.path,
            status: status,
            remaining: remaining,
            limit: limit,
            reset: reset
          }

          instrumentation.instrument("zendesk.rate_limit", payload)
        end
      end
    end
  end
end

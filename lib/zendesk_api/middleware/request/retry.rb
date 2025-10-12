require "faraday/middleware"

module ZendeskAPI
  module Middleware
    # @private
    module Request
      # Faraday middleware to handle HTTP Status 429 (rate limiting) / 503 (maintenance)
      # @private
      class Retry < Faraday::Middleware
        DEFAULT_RETRY_AFTER = 10
        DEFAULT_ERROR_CODES = [429, 503]

        def initialize(app, options = {})
          super(app)
          @logger = options[:logger]
          @error_codes = (options.key?(:retry_codes) && options[:retry_codes]) ? options[:retry_codes] : DEFAULT_ERROR_CODES
          @retry_on_exception = (options.key?(:retry_on_exception) && options[:retry_on_exception]) ? options[:retry_on_exception] : false
          @instrumentation = options[:instrumentation]
        end

        def call(env)
          # Duplicate env for retries but keep attempt counter persistent
          original_env = env.dup
          original_env[:call_attempt] = (env[:call_attempt] || 0)

          exception_happened = false
          response = nil

          if @retry_on_exception
            begin
              response = @app.call(env)
            rescue => ex
              exception_happened = true
              exception = ex
            end
          else
            # Allow exceptions to propagate normally when not retrying
            response = @app.call(env)
          end

          if exception_happened
            original_env[:call_attempt] += 1
            seconds_left = DEFAULT_RETRY_AFTER.to_i
            @logger&.warn "An exception happened, waiting #{seconds_left} seconds... #{exception}"
            instrument_retry(original_env, "exception", seconds_left)
            sleep_with_logging(seconds_left)
            return @app.call(original_env)
          end

          # Retry once if response has a retryable error code
          if response && @error_codes.include?(response.env[:status])
            original_env[:call_attempt] += 1
            seconds_left = (response.env[:response_headers][:retry_after] || DEFAULT_RETRY_AFTER).to_i
            @logger&.warn "You may have been rate limited. Retrying in #{seconds_left} seconds..."
            instrument_retry(original_env, (response.env[:status] == 429) ? "rate_limited" : "server_error", seconds_left)
            sleep_with_logging(seconds_left)
            response = @app.call(original_env)
          end

          response
        end

        private

        def instrument_retry(env, reason, delay)
          return unless @instrumentation

          begin
            @instrumentation.instrument(
              "zendesk.retry",
              {
                attempt: env[:call_attempt],
                endpoint: env[:url]&.path,
                method: env[:method],
                reason: reason,
                delay: delay
              }
            )
          rescue => e
            @logger&.debug("zendesk.retry instrumentation failed: #{e.message}")
          end
        end

        def sleep_with_logging(seconds_left)
          seconds_left.times do |i|
            sleep 1
            time_left = seconds_left - i
            @logger&.warn "#{time_left}..." if time_left > 0 && time_left % 5 == 0
          end
          @logger&.warn "" if seconds_left > 0
        end
      end
    end
  end
end

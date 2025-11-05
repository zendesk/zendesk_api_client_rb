# frozen_string_literal: true

require 'faraday/middleware'

module ZendeskAPI
  module Middleware
    # @private
    module Request
      # Faraday middleware to handle HTTP Status 429 (rate limiting) / 503 (maintenance)
      # @private
      class Retry < Faraday::Middleware
        DEFAULT_RETRY_AFTER = 10
        DEFAULT_ERROR_CODES = [429, 503].freeze

        def initialize(app, options = {})
          super(app)
          @logger = options[:logger]
          @error_codes = options.key?(:retry_codes) && options[:retry_codes] ? options[:retry_codes] : DEFAULT_ERROR_CODES
          @retry_on_exception = options.key?(:retry_on_exception) && options[:retry_on_exception] ? options[:retry_on_exception] : false
          @instrumentation = options[:instrumentation]
        end

        def call(env)
          original_env = env.dup
          exception_happened = false
          exception = nil

          if @retry_on_exception
            begin
              response = @app.call(env)
            rescue StandardError => e
              exception_happened = true
              exception = e
            end
          else
            response = @app.call(env)
          end

          if exception_happened || @error_codes.include?(response.env[:status])
            if exception_happened
              seconds_left = DEFAULT_RETRY_AFTER.to_i
              @logger&.warn "An exception happened, waiting #{seconds_left} seconds... #{exception}"
            else
              seconds_left = (response.env[:response_headers][:retry_after] || DEFAULT_RETRY_AFTER).to_i
            end

            @logger&.warn "You have been rate limited. Retrying in #{seconds_left} seconds..."

            if @instrumentation
              attempt = (env[:zendesk_retry_attempt] || 1) + 1
              reason = if exception_happened
                         'exception'
                       elsif response.env[:status] == 429
                         'rate_limited'
                       else
                         'service_unavailable'
                       end

              begin
                @instrumentation.instrument('zendesk.retry',
                                            attempt: attempt,
                                            endpoint: original_env[:url]&.path,
                                            method: original_env[:method],
                                            delay: seconds_left,
                                            reason: reason)
              rescue StandardError => e
                @logger&.debug("zendesk.retry instrumentation failed: #{e.message}")
              end
            end

            seconds_left.times do |i|
              sleep 1
              time_left = seconds_left - i
              @logger&.warn "#{time_left}..." if time_left.positive? && (time_left % 5).zero?
            end

            @logger&.warn ''

            original_env[:zendesk_retry_attempt] = (env[:zendesk_retry_attempt] || 1) + 1
            @app.call(original_env)
          else
            response
          end
        end
      end
    end
  end
end

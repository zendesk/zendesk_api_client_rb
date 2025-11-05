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
        end

        def call(env)
          original_env = env.dup
          exception_happened = false
          if @retry_on_exception
            begin
              response = @app.call(env)
            rescue => e
              exception_happened = true
            end
          else
            response = @app.call(env)
          end

          if exception_happened || @error_codes.include?(response.env[:status])

            if exception_happened
              seconds_left = DEFAULT_RETRY_AFTER.to_i
              @logger.warn "An exception happened, waiting #{seconds_left} seconds... #{e}" if @logger
            else
              seconds_left = (response.env[:response_headers][:retry_after] || DEFAULT_RETRY_AFTER).to_i
            end

            @logger.warn "You have been rate limited. Retrying in #{seconds_left} seconds..." if @logger

            seconds_left.times do |i|
              sleep 1
              time_left = seconds_left - i
              @logger.warn "#{time_left}..." if time_left > 0 && time_left % 5 == 0 && @logger
            end

            @logger.warn "" if @logger

            @app.call(original_env)
          else
            response
          end
        end
      end
    end
  end
end

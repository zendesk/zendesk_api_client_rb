module Zendesk
  module Request
    # Faraday middleware to handle HTTP Status 429 (rate limiting) / 503 (maintenance)
    class RetryMiddleware < Faraday::Middleware
      DEFAULT_RETRY_AFTER = 10
      ERROR_CODES = [429, 503]

      def call(env)
        response = @app.call(env)

        if ERROR_CODES.include?(response.env[:status])
          seconds_left = (response.env[:response_headers][:retry_after] || DEFAULT_RETRY_AFTER).to_i
          print "You have been rate limited. Retrying in #{seconds_left} seconds..."

          seconds_left.times do |i|
            sleep 1
            time_left = seconds_left - i
            print "#{time_left}..." if time_left > 0 && time_left % 5 == 0
          end

          puts

          @app.call(env)
        else
          response
        end
      end
    end
  end
end

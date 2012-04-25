module Zendesk
  module Request
    # Faraday middleware to handle HTTP Status 429 (rate limiting) / 503 (maintenance)
    class RetryMiddleware < Faraday::Middleware
      def call(env)
        response = @app.call(env)

        if [429, 503].include?(response.env[:status])
          seconds_left = (response.env[:response_headers][:retry_after] || 10).to_i
          end_time = Time.now + seconds_left + 1
          print "You have been rate limited. Retrying in #{seconds_left} seconds..."
          
          until end_time <= Time.now
            sleep(1)
            time_left = (end_time - Time.now).to_i
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

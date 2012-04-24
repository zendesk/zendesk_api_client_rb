module Zendesk
  module Request
    class RetryMiddleware < Faraday::Middleware
      def call(env)
        response = @app.call(env)

        if response.env[:status] == 429
          seconds_left = response.env[:response_headers][:retry_after].to_i
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

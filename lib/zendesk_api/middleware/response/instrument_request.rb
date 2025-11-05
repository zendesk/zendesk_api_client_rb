require 'faraday/middleware'

module ZendeskAPI
  module Middleware
    module Response
      # Response middleware that emits instrumentation events for requests
      # and rate limit headers when an instrumentation backend is configured.
      class InstrumentRequest < Faraday::Middleware
        def initialize(app, client)
          super(app)
          @client = client
        end

        def call(env)
          instrumentation = @client.config.instrumentation
          return @app.call(env) unless instrumentation

          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          @app.call(env).on_complete do |response_env|
            duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000.0
            status = response_env[:status]

            # Emit request duration for successful requests
            if status.nil? || status.to_i < 400
              begin
                instrumentation.instrument('zendesk.request',
                                           :duration => duration,
                                           :endpoint => response_env[:url]&.path,
                                           :method => response_env[:method],
                                           :status => status)
              rescue StandardError => e
                @client.config.logger&.debug("Instrumentation error: #{e.message}")
              end
            end

            # Emit rate limit information if headers are present
            if status.to_i < 500
              headers = response_env[:response_headers]
              if headers
                remaining = headers['x-rate-limit-remaining'] || headers['X-Rate-Limit-Remaining']
                limit = headers['x-rate-limit'] || headers['X-Rate-Limit']

                if remaining || limit
                  begin
                    instrumentation.instrument('zendesk.rate_limit',
                                               :endpoint => response_env[:url]&.path,
                                               :status => status,
                                               :remaining => remaining&.to_i,
                                               :threshold => limit&.to_i)
                  rescue StandardError => e
                    @client.config.logger&.debug("Instrumentation error: #{e.message}")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

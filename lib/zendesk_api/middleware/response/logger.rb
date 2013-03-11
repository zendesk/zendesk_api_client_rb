require 'faraday_middleware/response_middleware'

module ZendeskAPI
  module Middleware
    module Response
      # Faraday middleware to handle logging
      # @private
      class Logger < Faraday::Response::Middleware
        def initialize(app, logger = nil)
          super(app)

          @logger = logger || begin
            require 'logger'
            ::Logger.new(STDOUT)
          end
        end

        def call(env)
          @logger.info "#{env[:method]} #{env[:url].to_s}"
          @logger.debug dump_debug(env, :request_headers)

          @app.call(env).on_complete do |env|
            @logger.info("Status #{env[:status].to_s}")
            @logger.debug dump_debug(env, :response_headers)
          end
        end

        private

        def dump_debug(env, headers_key)
          info = env[headers_key].map { |k, v| "  #{k}: #{v.inspect}" }.join("\n")
          unless env[:body].nil?
            info.concat("\n")
            info.concat(env[:body].inspect)
          end
          info
        end
      end
    end
  end
end

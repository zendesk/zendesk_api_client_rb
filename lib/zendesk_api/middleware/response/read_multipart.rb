module ZendeskAPI
  module Middleware
    module Response
      class ReadMultipart < Faraday::Middleware
        def on_complete(env)
          puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
          return unless env[:body].is_a?(Faraday::Multipart::CompositeReadIO)

          env[:body] = read_multipart(env[:body])
        end

        private

        def read_multipart(body)
          env[:body].read
        ensure
          env[:body].close
        end
      end
    end
  end
end

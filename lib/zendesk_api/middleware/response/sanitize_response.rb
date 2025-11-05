module ZendeskAPI
  module Middleware
    module Response
      class SanitizeResponse < Faraday::Middleware
        def on_complete(env)
          env[:body].scrub!("")
        end
      end
    end
  end
end

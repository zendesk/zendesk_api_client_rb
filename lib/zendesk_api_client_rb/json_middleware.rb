module Zendesk
  module Response
    class JSONMiddleware < Faraday::Middleware
      dependency { require 'yajl' }

      def initialize(app)
        super(app)
      end

      def call(env)
        @app.call(env)
      end
    end
  end
end

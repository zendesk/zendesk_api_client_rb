module Zendesk
  module Request
    class ErrorMiddleware < Faraday::Middleware
      def initialize(app)
        super(app)
      end

      def call(env)
        @app.call(env)
        # Log errors/404s?
      end
    end
  end
end

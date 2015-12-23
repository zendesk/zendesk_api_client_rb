require "faraday/response"

module ZendeskAPI
  module Middleware
    module Response
      # @private
      class Callback < Faraday::Response::Middleware
        def initialize(app, callbacks)
          super(app)
          @callbacks = callbacks
        end

        def call(env)
          @app.call(env).on_complete do |env|
            @callbacks.each {|c| c.call(env)}
          end
        end
      end
    end
  end
end

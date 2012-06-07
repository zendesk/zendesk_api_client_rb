require "faraday/response"

module ZendeskAPI
  module Middleware
    module Response
      class Callback < Faraday::Response::Middleware
        def initialize(app, client)
          super(app)
          @client = client
        end

        def on_complete(env)
          super(env)
          @client.callbacks.each {|c| c.call(env)}
        end
      end
    end
  end
end

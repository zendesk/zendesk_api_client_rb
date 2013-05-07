require 'zendesk_api/error'

module ZendeskAPI
  module Middleware
    module Response
      class RaiseError < Faraday::Response::RaiseError
        def on_complete(env)
          case env[:status]
          when 404
            raise Error::RecordNotFound.new(env)
          when 422
            raise Error::RecordInvalid.new(env)
          when 400...600
            raise Error::NetworkError.new(env)
          end
        end
      end
    end
  end
end

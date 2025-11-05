require 'base64'
module ZendeskAPI
  # @private
  module Middleware
    # @private
    module Request
      # ApiTokenImpersonate
      # If Thread.current[:zendesk_thread_local_username] is set, it will modify the Authorization header
      # to impersonate that user using the API token from the current Authorization header.
      class ApiTokenImpersonate < Faraday::Middleware
        def call(env)
          if Thread.current[:zendesk_thread_local_username] && env[:request_headers][:authorization] =~ /^Basic /
            current_u_p_encoded = env[:request_headers][:authorization].split(/\s+/)[1]
            current_u_p = Base64.urlsafe_decode64(current_u_p_encoded)
            unless current_u_p.include?("/token:") && (parts = current_u_p.split(":")) && parts.length == 2 && parts[0].include?("/token")
              warn "WARNING: ApiTokenImpersonate passed in invalid format. It should be in the format username/token:APITOKEN"
              return @app.call(env)
            end

            next_u_p = "#{Thread.current[:zendesk_thread_local_username]}/token:#{parts[1]}"
            env[:request_headers][:authorization] = "Basic #{Base64.urlsafe_encode64(next_u_p)}"
          end
          @app.call(env)
        end
      end
    end
  end
end

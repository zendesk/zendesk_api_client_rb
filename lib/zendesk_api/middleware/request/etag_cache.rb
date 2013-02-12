require "faraday/middleware"

module ZendeskAPI
  module Middleware
    module Request
      # Request middleware that caches responses based on etags
      # can be removed once this is merged: https://github.com/pengwynn/faraday_middleware/pull/42
      # @private
      class EtagCache < Faraday::Middleware
        def initialize(app, options = {})
          @app = app
          @cache = options[:cache] ||
            raise("need :cache option e.g. ActiveSupport::Cache::MemoryStore.new")
          @cache_key_prefix = options.fetch(:cache_key_prefix, :faraday_etags)
        end

        def cache_key(env)
          [@cache_key_prefix, env[:url].to_s]
        end

        def call(env)
          return @app.call(env) unless [:get, :head].include?(env[:method])

          # send known etag
          cached = @cache.read(cache_key(env))

          if cached
            env[:request_headers]["If-None-Match"] ||= cached[:response_headers]["Etag"]
          end

          @app.call(env).on_complete do
            if cached && env[:status] == 304 # not modified
              env[:body] = cached[:body]
            elsif env[:status] == 200 && env[:response_headers]["Etag"] # modified and cacheable
              @cache.write(cache_key(env), env)
            end
          end
        end
      end
    end
  end
end

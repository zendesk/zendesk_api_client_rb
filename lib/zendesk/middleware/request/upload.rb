require "faraday/middleware"
require "mime/types"

module ZendeskAPI
  module Middleware
    module Request
      class Upload < Faraday::Middleware
        def call(env)
          if env[:body] && env[:body][:file]
            file = env[:body].delete(:file)
            case file
            when File
              path = file.path
            when String
              path = file
            else
              warn "WARNING: Passed invalid filename #{file} of type #{file.class} to upload"
            end

            if path
              env[:body][:filename] ||= File.basename(path)
              mime_type = MIME::Types.type_for(path).first || "application/octet-stream"
              env[:body][:uploaded_data] = Faraday::UploadIO.new(path, mime_type)
            end
          end

          @app.call(env)
        end
      end
    end
  end
end

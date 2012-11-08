require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/reloader'

require 'compass'
require 'haml'

require 'coderay'
require 'coderay_bash'

require 'json'
require 'redcarpet'

module ZendeskAPI
  module Server
    require 'zendesk_api/server/helper'
    require 'zendesk_api/server/html_renderer'

    class App < Sinatra::Base
      enable :sessions

      helpers Sinatra::ContentFor
      helpers Helper

      configure do
        set :public_folder, File.join(File.dirname(__FILE__), 'public')
        set :views, File.join(File.dirname(__FILE__), 'templates')

        set :documentation_dir, File.join(File.dirname(__FILE__), "docs")

        documentation = Dir.glob(File.join(settings.documentation_dir, "*.md")).inject({}) do |docs, entry|
          body = HtmlRenderer.render(File.open(entry, &:read))
          headers = HtmlRenderer.markdown.renderer.headers.dup

          HtmlRenderer.markdown.renderer.headers.clear

          docs.merge(File.basename(entry, ".md") => { :body => body, :headers => headers })
        end

        set :documentation, documentation
        set :help, documentation["introduction"][:body]

        autocomplete = settings.documentation.inject([]) do |accum, (resource, content)|
          accum.push(resource)
          accum.concat(content[:headers].map {|header| "#{resource}##{header}"})
          accum
        end + ["help"]

        set :autocomplete, autocomplete
      end

      configure :development do
        register Sinatra::Reloader
      end

      get '/' do
        @get_params = {}
        haml :index, :format => :html5
      end

      post '/search' do
        if md = settings.documentation[params[:query]]
          md[:body]
        else
          settings.help
        end
      end

      post '/' do
        @method = (params.delete("method") || "get").downcase.to_sym
        @path = params.delete("path")
        @json = params.delete("json")
        @get_params = (params.delete("params") || {}).delete_if do |param|
          !param["name"] || !param["value"] || (param["name"].empty? && param["value"].empty?)
        end

        begin
          response = client.connection.send(@method, @path) do |request|
            request.params = @get_params.inject({}) do |accum, h|
              accum.merge(h["name"] => h["value"])
            end

            if @method != :get && !@json.empty?
              request.body = JSON.parse(@json)
            end

            set_request(request.to_env(client.connection))
          end
        rescue Faraday::Error::ConnectionFailed => e
          @error = "The connection failed"
        rescue Faraday::Error::ClientError => e
          set_response(e.response) if e.response
        rescue JSON::ParserError => e
          @error = "The JSON you attempted to send was invalid"
        rescue URI::InvalidURIError => e
          @error = "Please enter a subdomain"
        else
          set_response(:body => response.body,
            :headers => response.env[:response_headers],
            :status => response.env[:status])
        end

        haml :index, :format => :html5
      end
    end
  end
end

require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/reloader'

require 'compass'
require 'haml'

require 'coderay'
require 'coderay_bash'

require 'json'
require 'redcarpet'

require 'digest/md5'

require 'mongoid'

require 'zendesk_api/server/models/user_request'
Mongoid.load!(File.join(File.dirname(__FILE__), '..', '..', '..', 'config', 'mongoid.yml'))

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
        @url_params = {}
        haml :index, :format => :html5
      end

      get '/:object_id' do
        @user_request = UserRequest.where(:_id => Moped::BSON::ObjectId(params[:object_id])).first

        if @user_request
          params["username"] = @user_request.username
          params["url"] = @user_request.url

          @method = @user_request.method
          @json = @user_request.json
          @url_params = @user_request.url_params
          @html_request = @user_request.request
          @html_response = @user_request.response
        end

        haml :index, :foramt => :html5
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
        @url_params = (params.delete("params") || {}).delete_if do |param|
          !param["name"] || !param["value"] || (param["name"].empty? && param["value"].empty?)
        end

        execute

        @user_request = UserRequest.create(
          :username => params["username"],
          :method => @method,
          :url => params["url"],
          :json => @json,
          :url_params => @url_params,
          :request => @html_request,
          :response => @html_response
        )

        haml :index, :format => :html5
      end
    end
  end
end

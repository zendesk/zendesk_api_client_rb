require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/reloader'

require 'optparse'

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
      enable :method_override

      helpers Sinatra::ContentFor
      helpers Helper

      configure do
        set :public_folder, File.join(File.dirname(__FILE__), 'public')
        set :views, File.join(File.dirname(__FILE__), 'templates')
      end

      configure :development do
        require 'debugger'

        register Sinatra::Reloader
      end

      get '/' do
        @get_params = {}
        haml :index, :format => :html5
      end

      post '/search' do
        # TODO needs protection
        file = "/Users/stevendavidovitz/src/zendesk.github.com/tmp/#{params[:query]}.md"

        if File.exists?(file)
          md = File.open(file) {|f| f.read}
        else
          md = help
        end

        HtmlRenderer.render(md)
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
        else
          set_response(:body => response.body,
            :headers => response.env[:response_headers],
            :status => response.env[:status])
        end

        haml :index, :format => :html5
      end

      if $0 == __FILE__
        OptionParser.new {|op|
          op.on('-e env', 'Set the environment') {|val| set(:environment, val.to_sym)}
          op.on('-p port', 'Bind to a port') {|val| set(:port, val.to_i)}
          op.on('-o addr', 'Bind to a location') {|val| set(:bind, val)}
        }.parse!(ARGV.dup)

        run!
      end
    end
  end
end

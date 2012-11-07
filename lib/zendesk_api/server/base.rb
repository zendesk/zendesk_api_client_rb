require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/reloader'

require 'optparse'
require 'compass'
require 'haml'
require 'coderay'
require 'json'
require 'redcarpet'

require 'zendesk_api'
require 'zendesk_api/console/extensions'

require 'debugger'

class HtmlRenderer
  def self.render(text)
    markdown = Redcarpet::Markdown.new(RedcarpetRenderer, :fenced_code_blocks => true, :no_intra_emphasis => true, :tables => true)
    markdown.render(text)
  end

  def self.generate_id(text)
    text.strip.downcase.gsub(/[\s,]+/, '-')
  end

  class RedcarpetRenderer < Redcarpet::Render::HTML
    def header(text, level)
      icons = <<-END
        <i class=\"header-icon icon-plus\"></i>
        <i class=\"header-icon icon-minus hide\"></i>
      END

      "<h#{level} id=\"#{HtmlRenderer.generate_id(text)}\">
        #{icons if level == 3}
        #{text}
      </h#{level}>"
    end

    def block_code(code, language)
      if language
        code = CodeRay.scan(code, language).html(:wrap => nil)
      end

      "<pre>#{code}</pre>"
    end
  end
end


module ZendeskAPI
  module Server
    module Helpers
      def help
        <<-END
### Searching
### Routing
        END
      end

      def map_headers(headers)
        headers.map do |k,v|
          name = k.split("-").map(&:capitalize).join("-")
          "#{name}: #{v}"
        end.join("\n")
      end

      def set_request(request)
        @html_request = <<-END
HTTP/1.1 #{@method.to_s.upcase} #{request[:url]}
#{map_headers(request[:request_headers])}
        END

        if @method != :get && @json && !@json.empty?
          @json = CodeRay.scan(@json, :json).span
          @html_request << "\n\n#{@json}"
        end
      end

      def set_response(response)
        @html_response =<<-END
HTTP/1.1 #{response[:status]}
#{map_headers(response[:headers])}


#{CodeRay.scan(JSON.pretty_generate(response[:body]), :json).span}
        END
      end

      def client(params = params)
        ZendeskAPI::Client.new do |c|
          params.each do |key, value|
            value = "https://#{value}.zendesk.com/api/v2/" if key == 'url'
            c.send("#{key}=", value)
          end

          # require 'logger'
          # c.logger = Logger.new(STDOUT)

          c.allow_http = true if App.development?
        end
      end
    end

    class App < Sinatra::Base
      enable :sessions
      enable :method_override

      helpers Sinatra::ContentFor
      helpers Helpers

      configure do
        set :public_folder, File.join(File.dirname(__FILE__), 'public')
        set :views, File.join(File.dirname(__FILE__), 'templates')
      end

      configure :development do
        register Sinatra::Reloader
      end

      get '/' do
        @get_params = {}
        haml :index, :format => :html5
      end

      post '/search' do
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

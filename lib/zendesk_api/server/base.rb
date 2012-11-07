require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/reloader'

require 'optparse'
require 'compass'
require 'haml'
require 'coderay'

require 'zendesk_api'
require 'zendesk_api/console/extensions'

require 'debugger'

module ZendeskAPI
  module Server
    module Helpers
      def map_headers(headers)
        headers.map do |k,v|
          name = k.split("-").map(&:capitalize).join("-")
          "#{name}: #{v}"
        end.join("\n")
      end

      def set_response(response)
        @html_request = <<-END
HTTP/1.1 #{@method.to_s.upcase} #{response.env[:url]}
#{map_headers(response.env[:request_headers])}
        END

        if @method != :get && @json && !@json.empty?
          @json = CodeRay.scan(@json, :json).span
          @html_request << "\n\n#{@json}"
        end

        @html_response =<<-END
HTTP/1.1 #{response.env[:status]}
#{map_headers(response.env[:response_headers])}


#{CodeRay.scan(JSON.pretty_generate(response.body), :json).span}
        END
      end

      def url_for(overwrite = {})
        new_url = url
        new_params = params.merge(overwrite).map {|k,v| "#{k}=#{v}"}
        new_url += "?#{new_params.join("&")}"
      end

      def sort_by
        (params[:sort_by] || 'id').downcase.to_sym
      end

      def sort_order
        if !params[:sort_order] || params[:sort_order] =~ /asc/i
          :asc
        else
          :desc
        end
      end

      def format_headers
        @collection.format_headers
      end

      def format(resource)
        resource.format
      end

      def page
        page = params[:page].to_i
        page > 0 ? page : 1
      end

      def page_params(page = page)
        str = "page=#{page}"
        str += "&per_page=#{params[:per_page]}" if params[:per_page]
        str
      end

      def readable_resources
        ZendeskAPI::Client.resources.select do |resource|
          (resource.ancestors & [ZendeskAPI::Resource, ZendeskAPI::ReadResource]).any?
        end
      end

      def sub_resource_hash
        readable_resources.inject({}) do |map, resource|
          associations = resource.associations.select do |association|
            !association[:singular] || (false)
          end.map do |association|
            association[:path] || association[:name]
          end

          unless associations.empty?
            map[resource.resource_name] = associations
          end

          map
        end
      end

      def client(params = params)
        ZendeskAPI::Client.new do |c|
          params.each do |key, value|
            value = "https://#{value}.zendesk.com/api/v2/" if key == 'url'
            c.send("#{key}=", value)
          end

          require 'logger'
          c.logger = Logger.new(STDOUT)

          c.allow_http = true if App.development?
        end
      end

      module_function :readable_resources
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

      post '/' do
        puts params.inspect

        @method = (params.delete("method") || "get").downcase.to_sym
        @path = params.delete("path")
        @json = params.delete("json")
        @get_params = params.delete("params").delete_if do |param|
          !param["name"] || !param["value"] || (param["name"].empty? && param["value"].empty?)
        end

        puts params.inspect

        begin
          response = client.connection.send(@method, @path) do |request|
            request.params = @get_params.inject({}) do |accum, h|
              accum[h["name"]] = h["value"]
              accum
            end

            puts request.params.inspect

            if @method != :get && !@json.empty?
              request.body = JSON.parse(@json)
            end
          end
        rescue Faraday::Error::ConnectionFailed => e
          @error = "The connection failed"
        rescue Faraday::Error::ClientError => e
          @error = e.message
        rescue JSON::ParserError => e
          @error = "JSON was invalid"
        else
          set_response(response)
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

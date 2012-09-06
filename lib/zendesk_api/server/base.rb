require 'sinatra/base'
require 'sinatra/content_for'

require 'optparse'
require 'compass'
require 'haml'

require 'zendesk_api'
require 'zendesk_api/console/extensions'

require 'debugger'

module ZendeskAPI
  module Server
    module Helpers
      def uneditable?(attribute)
        @resource.respond_to?(:save) && %w{id url created_at updated_at}.include?(attribute.to_s)
      end

      def get_resource
        @resource = @klass.find(client, :id => params[:id])
      end

      def client_headers
        @client_headers ||= client.connection.headers.map do |k, v|
          "#{k}: #{v}"
        end
      end

      def response_headers
        @resource.response.headers.map do |k, v|
          "#{k}: #{v}"
        end
      end

      def collection
        @collection.to_a.tap do |collection|
          collection.sort_by! do |res|
            res.send(sort_by) || ""
          end

          collection.reverse! if sort_order == :desc
        end
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

      def next_page
        "#{url}?#{page_params(page + 1)}"
      end

      def previous_page
        "#{url}?#{page_params(page - 1)}"
      end

      def readable_resources
        ZendeskAPI::Client.resources.select do |resource|
          (resource.ancestors & [ZendeskAPI::Resource, ZendeskAPI::ReadResource]).any?
        end
      end

      def setup_client(params = {})
        ZendeskAPI::Client.new do |c|
          params.each do |key, value|
            value = "https://#{value}.zendesk.com/api/v2/" if key == 'url'
            c.send("#{key}=", value)
          end

          c.allow_http = true if App.development?
        end
      end

      def client
        begin
          setup_client(session[:client])
        rescue => e
          session[:client] = nil
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

      get '/' do
        haml :index, :format => :html5
      end

      delete '/client' do
        session[:client] = nil
        redirect '/'
      end

      post '/client' do
        begin
          setup_client(params)
        rescue => e
          status 422
          body e.message
        else
          session[:client] = params.dup.tap do |p|
            p.default = nil # Rack can't dump a hash with a default
          end

          status 200
        end
      end

      Helpers.readable_resources.each do |resource|
        get "/#{resource.resource_name}" do
          @resource = resource
          @collection = ZendeskAPI::Collection.new(client, resource, params)
          haml :collection, :format => :html5
        end

        get "/#{resource.resource_name}/:id" do
          @klass = resource
          haml :resource, :format => :html5
        end

        put "/#{resource.resource_name}/:id" do |id|
          @klass = resource
          @resource = resource.find(client, :id => id)
          @resource.attributes.merge!(params[resource.singular_resource_name])

          @json_request =<<-EOF
#{client_headers.join("\n")}

#{JSON.pretty_generate(@resource.attributes)}
          EOF

          @success = @resource.save

          @json_response =<<-EOF
#{response_headers.join("\n")}

#{JSON.pretty_generate(@resource.response.body)}
          EOF

          haml :resource, :format => :html5
        end
      end

      OptionParser.new {|op|
        op.on('-e env', 'Set the environment') {|val| set(:environment, val.to_sym)}
        op.on('-p port', 'Bind to a port') {|val| set(:port, val.to_i)}
        op.on('-o addr', 'Bind to a location') {|val| set(:bind, val)}
      }.parse!(ARGV.dup)

      run!
    end
  end
end

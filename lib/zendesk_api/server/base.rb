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
      def readable_resources
        ZendeskAPI::Client.resources.select do |resource|
          (resource.ancestors & [ZendeskAPI::Resource, ZendeskAPI::ReadResource]).any?
        end
      end

      def setup_client(params = {})
        ZendeskAPI::Client.new do |c|
          params.each do |key, value|
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

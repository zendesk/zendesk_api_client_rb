require 'sinatra/base'
require 'optparse'

require 'compass'
require 'haml'

require 'zendesk_api/console/extensions'

class ZendeskAPI::Server < Sinatra::Base
  configure do
    set :public_folder, File.join(File.dirname(__FILE__), 'public')
    set :views, File.join(File.dirname(__FILE__), 'templates')
  end

  get '/' do
    haml :index, :format => :html5
  end

  OptionParser.new {|op|
    op.on('-e env', 'Set the environment') {|val| set(:environment, val.to_sym)}
    op.on('-p port', 'Bind to a port') {|val| set(:port, val.to_i)}
    op.on('-o addr', 'Bind to a location') {|val| set(:bind, val)}
  }.parse!(ARGV.dup)

  run!
end

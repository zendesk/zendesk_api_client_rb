require 'sinatra/base'
require 'optparse'

class ZendeskAPI::Server < Sinatra::Base
  get '/' do
    "Hi!!!!"
  end

  OptionParser.new {|op|
    op.on('-e env', 'Set the environment') {|val| set(:environment, val.to_sym)}
    op.on('-p port', 'Bind to a port') {|val| set(:port, val.to_i)}
    op.on('-o addr', 'Bind to a location') {|val| set(:bind, val)}
  }.parse!(ARGV.dup)

  run!
end

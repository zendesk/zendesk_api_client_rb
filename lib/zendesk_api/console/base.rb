require 'zendesk_api/console/extensions'
require 'zendesk_api/console/console'

extend ZendeskAPI::Console

require 'zendesk_api/console/options'
require 'ripl'

ARGV.clear
Ripl.shell.prompt = lambda { "#{cwd.respond_to?(:path) ? '/' + cwd.path : cwd} > " }
Ripl.shell.extend ZendeskAPI::Console::Eval
Ripl.start

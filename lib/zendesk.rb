require "rubygems"
require "bundler/setup"

if RUBY_VERSION =~ /1.8/
  require 'ruby-debug'
  Debugger.settings[:autoeval] = true
end

require 'zendesk/zendesk'

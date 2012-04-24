require 'rake/testtask'
require 'bundler/gem_tasks'

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new

desc "Run irb with zendesk client lib loaded"
task :console do
  sh "bundle exec irb -I lib -r ./lib/zendesk.rb"
end

desc 'Default: run specs.'
task :default => :spec
